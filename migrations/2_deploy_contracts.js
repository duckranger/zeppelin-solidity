var Ownable = artifacts.require("ownership/Ownable.sol");
var SampleRoleBasedAccess = artifacts.require("examples/SampleRoleBasedAccess.sol");
var Secured = artifacts.require("rbac/Secured.sol");
var RoleDirectory = artifacts.require("rbac/RoleDirectory.sol");

module.exports = function(deployer) {
  
	deployer.deploy(Ownable);
	deployer.deploy(RoleDirectory);
	deployer.deploy(Secured,RoleDirectory);
	deployer.deploy(SampleRoleBasedAccess);
};
