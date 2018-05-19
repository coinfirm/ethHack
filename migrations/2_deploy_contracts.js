var Exec = artifacts.require("./ExecuteSignedMVP.sol");

module.exports = function(deployer) {
  deployer.deploy(Exec, {value: 50000000000000000000});
};
