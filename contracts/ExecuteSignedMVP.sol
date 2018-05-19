pragma solidity ^0.4.23;

contract ExecuteSignedMVP{

    address public owner;

    event gaz(uint256 _gas);
    event signedVerifySign(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s);
    event notSignedVerifySign(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s);

    event returnAddress(address a);

    struct Key {
        address _key;
    }

    mapping(uint => Key) keys;

    uint private keysCounter = 0;

    constructor() public
    {
        owner = msg.sender;
        keys[keysCounter++]._key = owner;
    }

    function keysSize() public view returns(uint)
    {
        return keysCounter;
    }

    function removeKey(uint _id) public
    {
        require(owner == msg.sender);
        delete keys[_id];
    }

    function getKey(uint _id) public view returns(address)
    {
        address a = keys[_id]._key;
        return a;
    }

    function doKeyExist(address _a) public view returns(bool)
    {
        for(uint id = 0; id < keysCounter; id++)
        {
            if (_a == keys[id]._key)
            {
                return true;
            }
        }
    }

    function addKey(address _address) public
    {
        keys[keysCounter++]._key = _address;
    }

    function executeSigned(
        address _to,
        uint256 _value, 
        bytes _data, 
        bytes32 _hash,
        uint8 _v, 
        bytes32 _r,
        bytes32 _s
      ) 
      public returns(bool)
    {
        uint256 gasStart;
        uint256 gasUsed;
        uint256 bonus;
        uint256 result;
        gasStart = gasleft();
        if (doKeyExist(ecrecover(_hash, _v, _r, _s)))
        {
            bool status = _to.call.value(_value)(_data);

            gasUsed = (gasStart - gasleft() + 35000);
            bonus = (gasUsed / 100 ) * 5;

            result = gasUsed + bonus;
            msg.sender.transfer(result**9);
            return status;
        }
        else
        {
            gasUsed = (gasStart - gasleft() + 35000);
            bonus = (gasUsed / 100 ) * 5;

            result = gasUsed + bonus;
            msg.sender.transfer(result**9);
            return false;
        }
    }

    function verifySign(address _p, bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) private pure returns(bool)
    {
        // Note: this only verifies that signer is correct.
        // You'll also need to verify that the hash of the data
        // is also correct.

        // ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address):
        // recover address associated with the public key from elliptic curve signature,
        //return zero on error
        //emit returnAddress(ecrecover(hash, v, r, s));
        return ecrecover(_hash, _v, _r, _s) == _p;
    }
    /*
        function verifySign(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) private returns(bool)
        {
            bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            bytes32 prefixedHash = keccak256(prefix, hash);
            emit returnAddress(ecrecover(prefixedHash, v, r, s));
            return ecrecover(prefixedHash, v, r, s) == signer;
        }
    */

    function kill() public
    {
        selfdestruct(owner);
    }
}