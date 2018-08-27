var DeviceCustody = artifacts.require("./DeviceCustody.sol");

module.exports = function(deployer) {
  deployer.deploy(DeviceCustody);
};
