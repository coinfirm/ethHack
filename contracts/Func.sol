pragma solidity ^0.4.23;

contract Func {

    address public last;

    function setLast() public
    {
        last = msg.sender;
    }

    string public text;

    function setText(string _text)
    {
        text = _text;
    }

    uint256 number;
    function setNumber(uint256 _number) public
    {
        number = _number;
    }

    function sum(uint256 a, uint256 b) public pure returns (uint256)
    {
        return a + b;
    }

    function bark() public pure returns (string)
    {
        return "I do bark";
    }

    function echoSender() public view returns (address)
    {
        return msg.sender;
    }

}