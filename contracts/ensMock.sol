pragma solidity ^0.4.23;

contract ensMock {
    mapping (string => address) ens;

    constructor () public {
        add("hack.eth", 0xb0201641d9b936eb20155a38439ae6ab07d85fbd);
    }

    function add(string name, address a) public {
        ens[name] = a;
    }

    function get(string name) public view returns(address) {
        return ens[name];
    }

}