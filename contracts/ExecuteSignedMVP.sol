pragma solidity ^0.4.21;

contract ExecuteSignedMVP{

    address public owner;

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
        /*
                bytes32 _hash = 0xe38d912e5b3f9731997644f985b4d246ce75ec73109c3cbeeaeb2ae437bba44f;
                uint8 _v = 27;
                bytes32 _r = 0x81be64f2074fcf7a3b744d035683e48901f19233949e8f60eba849a355e8d6e3;
                bytes32 _s = 0x08a708eb4873f94a3ace43c5a5860c9dba86dadf33113c58c854ec3b0df459b3;
        */

        //emit returnAddress(ecrecover(_hash, _v, _r, _s));
        if (doKeyExist(ecrecover(_hash, _v, _r, _s)))
        {
            bool success = _to.call.value(_value)(_data);
            return true;
        }
        else
        {
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