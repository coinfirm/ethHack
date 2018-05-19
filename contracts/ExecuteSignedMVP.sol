pragma solidity ^0.4.21;

contract ExecuteSignedMVP{

    address public owner;

    event signedVerifySign(bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event notSignedVerifySign(bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event signedIsSigned(bytes32 hash, uint8 v, bytes32 r, bytes32 s);
    event notSignedIsSigned(bytes32 hash, uint8 v, bytes32 r, bytes32 s);

    event returnAddress(address a);

    event eventreturnBytes32(bytes32 data);
    event eventreturnBytes(bytes data);
    event eventreturnUint8(uint8 data);

    function ExecuteSignedMVP() public
    {
        owner = msg.sender;
    }

    function returnBytes32(bytes32 data) public returns(bytes32)
    {
        emit eventreturnBytes32(data);
        return data;
    }

    function returnBytes(bytes data) public returns(bytes)
    {
        emit eventreturnBytes(data);
        return data;
    }

    function returnUint8(uint8 data) public returns(uint8)
    {
        emit eventreturnUint8(data);
        return data;
    }

    //function executeSigned(address to, address from, uint256 value, bytes data, uint nonce, uint gasPrice, uint gasLimit, address gasToken, operationType bytes messageSignatures) public returns(bool){
    function executeSigned(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public returns(bool)
    {
        /*
                bytes32 hash = 0xe38d912e5b3f9731997644f985b4d246ce75ec73109c3cbeeaeb2ae437bba44f;
                uint8 v = 27;
                bytes32 r = 0x81be64f2074fcf7a3b744d035683e48901f19233949e8f60eba849a355e8d6e3;
                bytes32 s = 0x08a708eb4873f94a3ace43c5a5860c9dba86dadf33113c58c854ec3b0df459b3;
        */
        emit returnAddress(ecrecover(hash, v, r, s));
        if (verifySign(owner, hash, v, r, s))
        {
            emit signedVerifySign(hash, v, r, s);
        }
        else
        {
            emit notSignedVerifySign(hash, v, r, s);
        }

        if (isSigned(owner, hash, v, r, s))
        {
            emit signedIsSigned(hash, v, r, s);
        }
        else
        {
            emit notSignedIsSigned(hash, v, r, s);
        }

        return true;
    }

    function isSigned(address p, bytes32 hash, uint8 v, bytes32 r, bytes32 s) private returns(bool)
    {
        // Note: this only verifies that signer is correct.
        // You'll also need to verify that the hash of the data
        // is also correct.

        // ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address):
        // recover address associated with the public key from elliptic curve signature,
        //return zero on error
        emit returnAddress(ecrecover(hash, v, r, s));
        return ecrecover(hash, v, r, s) == p;
    }

    function verifySign(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) private returns(bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, hash);
        emit returnAddress(ecrecover(prefixedHash, v, r, s));
        return ecrecover(prefixedHash, v, r, s) == signer;
    }

    function kill() public
    {
        selfdestruct(owner);
    }
}