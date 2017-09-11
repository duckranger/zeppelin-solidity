const assertJump = require('./helpers/assertJump');
var RoleDirectory = artifacts.require('../contracts/rbac/RoleDirectory.sol');

contract('RoleDirectory', function(accounts) {
  let roleDirectory;

  beforeEach(async function() {
    roleDirectory = await RoleDirectory.new();
    await roleDirectory.addSystemRole('role_1');
  });

  it("should store new role", async function() {
    let result = await roleDirectory.roleExists('role_1');
    assert.isTrue(result);
  });

  it("should not allow double role", async function() {
    try {
      let result = await roleDirectory.addSystemRole('role_1');
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });



  it("should not have a role that was not added", async function() {
    let result = await roleDirectory.roleExists('role_2');
    assert.isFalse(result);
  });

  it("should be able to contain multiple roles", async function() {
    await roleDirectory.addSystemRole('role_2');
    await roleDirectory.addSystemRole('role_3');
    let role1Exists = await roleDirectory.roleExists('role_1');
    let role2Exists = await roleDirectory.roleExists('role_2');
    let role3Exists = await roleDirectory.roleExists('role_3');
    assert.isTrue(role1Exists && role2Exists && role3Exists);
  });

  it("should assign a role to a user", async function() {
    await roleDirectory.addRoleToUser(1,'role_1');
    let userHasRole = await roleDirectory.userInRole(1,'role_1');
    assert.isTrue(userHasRole);
  });

  it("should not assign an extra role to user", async function() {
    await roleDirectory.addSystemRole('role_2');
    await roleDirectory.addRoleToUser(1,'role_1');
    let userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    let userHasRole2 = await roleDirectory.userInRole(1,'role_2');
    assert.isTrue(userHasRole1);
    assert.isFalse(userHasRole2);
  });

  it("should allow users to have multiple roles", async function() {
    await roleDirectory.addSystemRole('role_2');
    await roleDirectory.addRoleToUser(1,'role_1');
    await roleDirectory.addRoleToUser(1,'role_2');
    let userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    let userHasRole2 = await roleDirectory.userInRole(1,'role_2');
    assert.isTrue(userHasRole1);
    assert.isTrue(userHasRole2);
  });

  it("should find exact role", async function() {
    await roleDirectory.addRoleToUser(1,'role_1');
    let userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    assert.isTrue(userHasRole1);
  });

  it("should be able to remove role from a user", async function() {
    await roleDirectory.addSystemRole('role_2');
    await roleDirectory.addRoleToUser(1,'role_1');
    await roleDirectory.addRoleToUser(1,'role_2');
    let userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    let userHasRole2 = await roleDirectory.userInRole(1,'role_2');

    // assert user has both roles before removing any
    assert.isTrue(userHasRole1);
    assert.isTrue(userHasRole2);

    // remove role2, assert it is gone, and that the user still has role1
    await roleDirectory.removeRoleFromUser(1,'role_2');
    userHasRole2 = await roleDirectory.userInRole(1,'role_2');
    assert.isFalse(userHasRole2);
    userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    assert.isTrue(userHasRole1);

    // remove role1, assert it is gone.
    await roleDirectory.removeRoleFromUser(1,'role_1');
    userHasRole1 = await roleDirectory.userInRole(1,'role_1');
    assert.isFalse(userHasRole1);
  });
});
