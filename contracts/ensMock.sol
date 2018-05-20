pragma solidity ^0.4.23;

contract ensMock {
    mapping (string => address) ens;

    constructor() public {
        add("hack.eth", 0xD2E8d9173584D4DaA5C8354a79eF75ceC2dfa228); // ID contract
    }

    function add(string name, address a) public {
        ens[name] = a;
    }

    function get(string name) public view returns(address) {
        return ens[name];
    }

}