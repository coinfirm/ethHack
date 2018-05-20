pragma solidity ^0.4.23;

contract ensMock {
<<<<<<< HEAD
    mapping (string => address) ens;

    constructor () public {
        add("hack.eth", 0xb0201641d9b936eb20155a38439ae6ab07d85fbd);
=======
    mapping(string => address) ens;

    constructor() public {
        add("hack.eth", 0xD2E8d9173584D4DaA5C8354a79eF75ceC2dfa228); // ID contract
>>>>>>> 225d8ae6db512a26fdb63ae7484944dc7db7cb6a
    }

    function add(string name, address a) public {
        ens[name] = a;
    }
<<<<<<< HEAD

    function get(string name) public view returns(address) {
        return ens[name];
    }

=======
>>>>>>> 225d8ae6db512a26fdb63ae7484944dc7db7cb6a
}