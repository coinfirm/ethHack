pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Func.sol";

contract Func_test {
    function testSum()
    {
        Func func = Func(DeployedAddresses.Func());

        uint256 expected = 15;

        Assert.equal(func.sum(10,5), expected, "Is not equal to expected");
    }
}