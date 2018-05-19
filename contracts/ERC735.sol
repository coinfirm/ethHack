pragma solidity ^0.4.21;

contract ERC735 {

    event ClaimRequested(bytes32 indexed claimRequestId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);   
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed claimType, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 claimType;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + claimType + data
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) public view returns(uint256 claimType, uint256 scheme, address issuer, bytes signature, bytes data, string uri);
    function getClaimIdsByType(uint256 _claimType) public view returns(bytes32[] claimIds);
    function addClaim(uint256 _claimType, uint256 _scheme, address _issuer, bytes _signature, bytes _data, string _uri) public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}