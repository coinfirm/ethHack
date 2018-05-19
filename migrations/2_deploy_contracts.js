var Exec = artifacts.require("./ExecuteSignedMVP.sol");

module.exports = function(deployer) {
  deployer.deploy(Exec);
};
