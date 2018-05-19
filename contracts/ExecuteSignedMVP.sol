pragma solidity ^0.4.21;

contract ExecuteSignedMVP{

    address public owner;

    event signedVerifySign(bytes data, bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event notSignedVerifySign(bytes data, bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event signedIsSigned(bytes data, bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event notSignedIsSigned(bytes data, bytes32 hash, uint8 v, bytes32 r, bytes32 s);

    function ExecuteSignedMVP() public
    {
        owner = msg.sender;
    }


    //function executeSigned(address to, address from, uint256 value, bytes data, uint nonce, uint gasPrice, uint gasLimit, address gasToken, operationType bytes messageSignatures) public returns(bool){
    function executeSigned(bytes data, bytes32 hash, uint8 v, bytes32 r, bytes32 s) public returns(uint)
    {
        if (verifySign(owner, hash, v, r, s))
        {
            return 1;
            // emit signedVerifySign(data, hash, v, r, s);
        }
        else
        {
            return 2;
            // emit notSignedVerifySign(data, hash, v, r, s);
        }

        if (isSigned(owner, hash, v, r, s))
        {
            return 3;
            // emit signedIsSigned(data, hash, v, r, s);
        }
        else
        {
            return 4;
            // emit notSignedIsSigned(data, hash, v, r, s);
        }
    }

    function isSigned(address p, bytes32 hash, uint8 v, bytes32 r, bytes32 s) pure private returns(bool)
    {
        // Note: this only verifies that signer is correct.
        // You'll also need to verify that the hash of the data
        // is also correct.

        // ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address):
        // recover address associated with the public key from elliptic curve signature,
        //return zero on error
        return ecrecover(hash, v, r, s) == p;
    }

    function verifySign(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) pure private returns(bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, hash);
        return ecrecover(prefixedHash, v, r, s) == signer;
    }

    function kill() public
    {
        selfdestruct(owner);
    }
}