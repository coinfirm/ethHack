pragma solidity ^0.4.23;
import "./SafeMath.sol";

contract ExecuteSignedMVP{

    address public owner;

    event checkSign(bool status);
    event signedVerifySign(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s);
    event notSignedVerifySign(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s);

    event returnAddress(address a);

    struct Key {
        address _key;
    }

    mapping(uint => Key) keys;

    uint private keysCounter = 0;

    constructor() public payable 
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
        delete keys[_id];
    }

    function getKey(uint _id) public view returns(address)
    {
        address returnAddressa = keys[_id]._key;
        return returnAddressa;
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
        bool status;
        gasStart = gasleft();
        address a = ecrecover(_hash,_v,_r,_s);

        emit returnAddress(a); // for test purpose, if returns something we are in

        if (doKeyExist(a))
        {
            status = _to.call.value(_value)(_data);
         }
        else
        {
            status = false;
        }
        gasUsed = SafeMath.add(SafeMath.sub(gasStart, gasleft()), 35000);
        bonus = SafeMath.mul(SafeMath.div(gasUsed,100), 5);

        result = SafeMath.add(gasUsed, bonus);
        msg.sender.transfer(SafeMath.mul(result,10**9));

        return status;
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