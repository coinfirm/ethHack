pragma solidity ^0.4.21;

import "./ERC725.sol";
import "./ERC735.sol";


contract Identity is ERC725, ERC735 {

    mapping (bytes32 => Key) keys;
    mapping (uint256 => bytes32[]) keysByPurpose;
    mapping (bytes32 => Claim) claims;
    mapping (uint256 => bytes32[]) claimsByType;

    mapping (bytes32 => uint256) indexes;
    mapping (uint256 => Transaction) txx;
    mapping (uint256 => uint256) purposeThreshold;
    
    uint256 nonce;
    address recoveryContract;
    address recoveryManager;

    struct Transaction {
        bool valid;
        address to;
        uint256 value;
        bytes data;
        uint256 nonce;
        uint256 approverCount;
        mapping(bytes32 => bool) approvals;
    }

    modifier managerOnly {
        require(
            isKeyPurpose(bytes32(msg.sender), MANAGEMENT_KEY)
        );
        _;
    }

    modifier managementOnly {
        if(msg.sender == address(this)) {
            _;
        } else {
            require(isKeyPurpose(bytes32(msg.sender), MANAGEMENT_KEY));
            if (purposeThreshold[MANAGEMENT_KEY] == 1) {
                _;
            } else {
                execute(address(this), 0, msg.data);
            }
        }
    }
    modifier recoveryOnly {
        require(
            recoveryContract != address(0) && 
            msg.sender == address(recoveryContract)
        );
        _;
    }

    modifier keyPurposeOnly(bytes32 _key, uint256 _purpose) {
        require(isKeyPurpose(_key, _purpose));
        _;
    }
    
    modifier managerOrActor(bytes32 _key) {
        require(
            isKeyPurpose(_key, MANAGEMENT_KEY) || 
            isKeyPurpose(_key, ACTION_KEY)
        );
        _;
    }
    
    function Identity() public {
        _constructIdentity(msg.sender);
    }    

    function () 
        public 
        payable 
    {

    }

    function managerReset(address _newKey) 
        public 
        recoveryOnly
    {
        recoveryManager = _newKey;
        _addKey(bytes32(recoveryManager), MANAGEMENT_KEY, 0);
        purposeThreshold[MANAGEMENT_KEY] = keysByPurpose[MANAGEMENT_KEY].length;
    }
    
    function processManagerReset(uint256 _limit) 
        public 
    {
        require(recoveryManager != address(0));
        uint256 limit = _limit;
        bytes32 newKey = bytes32(recoveryManager);
        bytes32[] memory managers = keysByPurpose[MANAGEMENT_KEY];
        uint256 totalManagers = managers.length;
        
        if (limit == 0) {
            limit = totalManagers;
        }

        purposeThreshold[MANAGEMENT_KEY] = totalManagers - limit + 1;
        for (uint256 i = 0; i < limit; i++) {
            bytes32 manager = managers[i];
            if (manager != newKey) {
                _removeKey(manager, MANAGEMENT_KEY);
                totalManagers--;
            }
        }

        if (totalManagers == 1) {
            recoveryManager = address(0);
        }
    }

    function addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _type
    )
        public
        managementOnly
        returns (bool success)
    {   
        _addKey(_key, _purpose, _type);
        return true;
    }

    function replaceKey(
        bytes32 _oldKey,
        bytes32 _newKey,
        uint256 _newType
    )
        public
        managementOnly
        returns (bool success)
    {
        uint256 purpose = keys[_oldKey].purpose;
        _addKey(_newKey, purpose, _newType);
        _removeKey(_oldKey, purpose);
        return true;
    } 

    function removeKey(
        bytes32 _key,
        uint256 _purpose
    )
        public
        managementOnly
        returns (bool success)
    {
        _removeKey(_key, _purpose);
        return true;
    }

    function execute(
        address _to,
        uint256 _value,
        bytes _data
    ) 
        public 
        returns (uint256 executionId)
    {
        uint256 requiredKey = _to == address(this) ? MANAGEMENT_KEY : ACTION_KEY;
        if (purposeThreshold[requiredKey] == 1) {
            executionId = nonce; //(?) useless in this case
            nonce++; //(?) should increment
            require(isKeyPurpose(bytes32(msg.sender), requiredKey));
            _to.call.value(_value)(_data); //(?) success not used
            emit Executed(executionId, _to, _value, _data); //no information on success
        } else {
            executionId = _execute(_to, _value, _data);
            approve(executionId, true);
        }
        
    }

    function approve(uint256 _id, bool _approval) 
        public 
        managerOrActor(bytes32(msg.sender))
        returns (bool success)
    {   
        return _approve(bytes32(msg.sender), _id, _approval);
    }

    function setMinimumApprovalsByKeyType(
        uint256 _purpose,
        uint256 _minimumApprovals
    ) 
        public 
        managementOnly
    {
        require(_minimumApprovals > 0);
        require(_minimumApprovals <= keysByPurpose[_purpose].length);
        purposeThreshold[_purpose] = _minimumApprovals;
    }
    
    
    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    ) 
        public 
        returns (bytes32 claimHash)
    {
        claimHash = keccak256(_issuer, _claimType);
        if (msg.sender == address(this)) {
            if (claims[claimHash].claimType > 0) {
                _modifyClaim(claimHash, _claimType, _scheme, _issuer, _signature, _data, _uri);
            } else {
                _includeClaim(claimHash, _claimType, _scheme, _issuer, _signature, _data, _uri);
            }
        } else {
            require(_issuer == msg.sender);
            require(isKeyPurpose(bytes32(msg.sender), CLAIM_SIGNER_KEY));
            _execute(address(this), 0, msg.data);
            emit ClaimRequested(
                claimHash,
                _claimType,
                _scheme,
                _issuer,
                _signature,
                _data,
                _uri
            );
        }
    }
    
    function removeClaim(bytes32 _claimId) 
        public 
        returns (bool success) 
    {
        Claim memory c = claims[_claimId];
        
        require(
            msg.sender == c.issuer ||
            msg.sender == address(this)
            );
        
        // MUST only be done by the issuer of the claim, or KEYS OF PURPOSE 1, or the identity itself.
        // TODO If its the identity itself, the approval process will determine its approval.
        
        uint256 claimIdTypePos = indexes[_claimId];
        delete indexes[_claimId];
        bytes32[] storage claimsTypeArr = claimsByType[c.claimType];
        bytes32 replacer = claimsTypeArr[claimsTypeArr.length-1];
        claimsTypeArr[claimIdTypePos] = replacer;
        indexes[replacer] = claimIdTypePos;
        delete claims[_claimId];
        claimsTypeArr.length--;
        return true;
    }

    function getKey(
        bytes32 _key,
        uint256 _purpose
    ) 
        public 
        view 
        returns(uint256 purpose, uint256 keyType, bytes32 key) 
    {
        Key storage myKey = keys[keccak256(_key, _purpose)];
        return (myKey.purpose, myKey.keyType, myKey.key);
    }
    
    function isKeyPurpose(bytes32 _key, uint256 _purpose) 
        public
        view 
        returns (bool)
    {
        return keys[keccak256(_key, _purpose)].purpose == _purpose;
    }

    function getKeyPurpose(bytes32 _key)
        public 
        view 
        returns(uint256[] purpose)
    {
        
        uint256[] memory purposeHolder = new uint256[](4);
        uint8 counter = 0;
        
        if (isKeyPurpose(_key, MANAGEMENT_KEY)) {
            purposeHolder[counter] = MANAGEMENT_KEY;
            counter++;
        }
        
        if (isKeyPurpose(_key, ACTION_KEY)) {
            purposeHolder[counter] = ACTION_KEY;
            counter++;
        }
            
        if (isKeyPurpose(_key, CLAIM_SIGNER_KEY)) {
            purposeHolder[counter] = CLAIM_SIGNER_KEY;
            counter++;
        }
            
        if (isKeyPurpose(_key, ENCRYPTION_KEY)) {
            purposeHolder[counter] = ENCRYPTION_KEY;
            counter++;
        }
        
        uint256[] memory result = new uint256[](counter);
        for (uint8 i = 0; i < counter; i++) {
            result[i] = purposeHolder[i];
        }
        
        return result;
    }
    
    function getKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[])
    {
        return keysByPurpose[_purpose];
    }
    
    function getClaim(bytes32 _claimId)
        public
        view 
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes signature,
            bytes data,
            string uri
            ) 
    {
        Claim memory _claim = claims[_claimId];
        return (_claim.claimType, _claim.scheme, _claim.issuer, _claim.signature, _claim.data, _claim.uri);
    }
    
    function getClaimIdsByType(uint256 _claimType)
        public
        view
        returns(bytes32[] claimIds)
    {
        return claimsByType[_claimType];
    }

    function setupRecovery(address _recoveryContract) 
        public
        managementOnly
    {
        require(recoveryContract == address(0));
        recoveryContract = _recoveryContract;
    }
    
    function _constructIdentity(address _manager)
        internal 
    {
        require(keysByPurpose[MANAGEMENT_KEY].length == 0);
        require(purposeThreshold[MANAGEMENT_KEY] == 0);
        _addKey(bytes32(_manager), MANAGEMENT_KEY, 0);

        purposeThreshold[MANAGEMENT_KEY] = 1;
        purposeThreshold[ACTION_KEY] = 1;
    }

    function _execute(
        address _to,
        uint256 _value,
        bytes _data
    ) 
        private
        returns (uint256 executionId)
    {
        executionId = nonce;
        nonce++;
        txx[executionId] = Transaction({
            valid: true,
            to: _to,
            value: _value,
            data: _data,
            nonce: nonce,
            approverCount: 0
        });            
        emit ExecutionRequested(executionId, _to, _value, _data);
    }
    
    function _approve(
        bytes32 _key,
        uint256 _id,
        bool _approval
    ) 
        private 
        returns(bool success) //(?) should return approved instead of success?
    {
        
        Transaction memory trx = txx[_id];
        require(trx.valid);
        uint256 requiredKeyPurpose = trx.to == address(this) ? MANAGEMENT_KEY : ACTION_KEY;
        require(isKeyPurpose(_key, requiredKeyPurpose));
        bytes32 keyHash = keccak256(_key, requiredKeyPurpose);
        require(txx[_id].approvals[keyHash] != _approval);
        
        if (_approval) {
            trx.approverCount++;
        } else {
            trx.approverCount--;
        }
    
        emit Approved(_id, _approval);

        if (trx.approverCount < purposeThreshold[requiredKeyPurpose]) {
            txx[_id].approvals[keyHash] = _approval;
            txx[_id] = trx;
        } else {
            delete txx[_id];
            //(?) success should be included in event?
            success = address(trx.to).call.value(trx.value)(trx.data);
            emit Executed(_id, trx.to, trx.value, trx.data);
            
        }
    }

    function _addKey(
        bytes32 _key,
        uint256 _purpose,
        uint256 _type
    ) 
        private
    {
        bytes32 keyHash = keccak256(_key, _purpose);
        
        require(keys[keyHash].purpose == 0);
        require(
            _purpose == MANAGEMENT_KEY ||
            _purpose == ACTION_KEY ||
            _purpose == CLAIM_SIGNER_KEY ||
            _purpose == ENCRYPTION_KEY
        );
        keys[keyHash] = Key(_purpose, _type, _key);
        indexes[keyHash] = keysByPurpose[_purpose].push(_key) - 1;
        emit KeyAdded(_key, _purpose, _type);
    }

    function _removeKey(
        bytes32 _key,
        uint256 _purpose
    )
        private 
    {
        if (_purpose == MANAGEMENT_KEY) {
            require(keysByPurpose[MANAGEMENT_KEY].length > purposeThreshold[MANAGEMENT_KEY]);
        }

        bytes32 keyHash = keccak256(_key, _purpose);
        Key memory myKey = keys[keyHash];
        uint256 index = indexes[keyHash];
        bytes32 indexReplacer = keysByPurpose[_purpose][keysByPurpose[_purpose].length - 1];
        
        keysByPurpose[_purpose][index] = indexReplacer;
        indexes[keccak256(indexReplacer, _purpose)] = index;
        keysByPurpose[_purpose].length--;

        delete indexes[keyHash];
        delete keys[keyHash];

        emit KeyRemoved(myKey.key, myKey.purpose, myKey.keyType);
    }

    function _includeClaim(
        bytes32 _claimHash,
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    ) 
        private
    {
        claims[_claimHash] = Claim(
            {
            claimType: _claimType,
            scheme: _scheme,
            issuer: _issuer,
            signature: _signature,
            data: _data,
            uri: _uri
            }
        );
        indexes[_claimHash] = claimsByType[_claimType].length;
        claimsByType[_claimType].push(_claimHash);
        emit ClaimAdded(
            _claimHash,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );
    }


    function _modifyClaim(
        bytes32 _claimHash,
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    ) 
        private
    {
        require(msg.sender == _issuer);
        claims[_claimHash] = Claim({
            claimType: _claimType,
            scheme: _scheme,
            issuer: _issuer,
            signature: _signature,
            data: _data,
            uri: _uri
        });
        emit ClaimChanged(
            _claimHash,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );
    }


}

