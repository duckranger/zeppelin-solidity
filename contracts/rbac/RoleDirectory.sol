pragma solidity ^0.4.11;

import '../ownership/Ownable.sol';

/**
 * @title RoleDirecory
 * @dev RoleDirecory is a simple directory that enables its user to define roles
 * and assign them to addresses (users)
 *
 * A role is constructed of a unique name (within the RoleDirecory) and a weight.
 * The weight of the role can be used by developers wanting to create a role
 * hierarchy. When the hasRole function is used, it will check that the caller has
 * either the exact role name, or a role that carries more weight.
 *
 * In a non-hierarchical situation, all roles can be created with the same weight.
 */
contract RoleDirectory is Ownable {

  struct RoleDetails {
    uint8 onBitPosition;
    address[] users;
  }
  // All the roles available in the system, mapped by Role name to the "on" bit
  // in the mask.
  // To get the mask for a specific role: 1 shift left 'on-bit'-1 e.g. if the on-bit value
  // is 6 then the mask is 1 << 5 => 100000
  // The maximum number of roles is controlled by the size of the mapping target of userRoles.
  mapping(string=>RoleDetails) private systemRoles;

  // Mapping of a user (address) to the set of Roles assigned to them. Note that
  // the set of roles is a uint32 mask which is created by adding all roles that
  // a user has.
  mapping(address=>uint32) private userRoles;

  // When adding a role, this is the position of the 'on bit' in the mask related
  // to this role. (Used for the shift_left operator)
  // This will be increased after the role is added.
  uint8 private nextRoleBitPosition = 1;

  // The maximum number of roles. To allow for more roles - the target
  // of mapping in userRoles needs to change.
  uint8 private maximumRoles = 32;

  // @dev Owner of the RoleDirectory may add new roles in the system.
  // The new role has to have a unique name
  // @param _name - the name of the new role
  function addRole(string _name) onlyOwner {
      require (!roleExists(_name));
      require (nextRoleBitPosition <= maximumRoles);
      systemRoles[_name].onBitPosition = nextRoleBitPosition;
      nextRoleBitPosition++;
  }

  // @dev Owner of the RoleDirectory may remove roles from the system.
  // It will also remove the role from all users that have it.
  // @param _name - the name of the new role
  function removeRole(string _role) onlyOwner {
      require (roleExists(_role));
      for (uint i = 0 ; i < systemRoles[_role].users.length; i++) {
        userRoles[systemRoles[_role].users[i]] &=  ~createMask(_role);
      }
      systemRoles[_role].onBitPosition = 0;
      systemRoles[_role].users.length = 0;
  }

  // @dev Adds a role to a user
  // If the user already has the role - it will not be added again.
  // @param _user - the address to add the role to
  // @param _role - the name of the role to add to the user
  function addRoleToUser(address _user, string _role) onlyOwner {
    require(roleExists(_role));
    if (!userInRole(_user, _role)) {
      systemRoles[_role].users.push(_user);
    }
    userRoles[_user] |=  createMask(_role);
  }

  // @dev remove a role from user
  // @param _user - the address to remove the role from
  // @param _role - the name of the role to remove
  function removeRoleFromUser(address _user, string _role) onlyOwner {
    require(roleExists(_role));
    var usersInRole = systemRoles[_role].users.length;
    userRoles[_user] &= ~createMask(_role);
    for (uint i = 0 ; i < systemRoles[_role].users.length; i++) {
      if (systemRoles[_role].users[i] == _user) {
        systemRoles[_role].users[i] = systemRoles[_role].users[usersInRole-1];
        systemRoles[_role].users.length--;
        break;
      }
    }
  }

  // @dev Checks whether the user has the role assigned
  // @param _user - the address to check the role for
  // @param _roleName - the role to check for
  // @return bool - whether the user has the role assigned to them
  function userInRole(address _user, string _roleName) constant returns (bool) {
    require(roleExists(_roleName));
    return userRoles[_user] & createMask(_roleName) > 0;
  }

  // @dev Checks whether a role exists in the system.
  // @param _name - the name to check.
  // @return bool - whether the role is registered in the system or not
  function roleExists(string _name) constant returns (bool) {
    require(bytes(_name).length > 0);
    return systemRoles[_name].onBitPosition > 0;
  }

  function createMask(string _roleName) internal constant returns (uint32) {
    return uint32(1 << (systemRoles[_roleName].onBitPosition-1));
  }
}
