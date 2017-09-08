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

  // A definition of a single Role in the system
  struct Role {
    string name;   //Role's name - must be unique
    uint8 weight;  //Role's weight
  }

  // All the roles available in the system, mapped by Role.name
  mapping(string=>Role) private systemRoles;

  // Mapping of a user (address) to the set of Roles assigned to them
  mapping(address=>Role[]) private userRoles;

  // @dev Owner of the RoleDirectory may add new roles in the system.
  // The new role has to have a unique name
  // @param _name - the name of the new role
  // @param _weight - weight to the role. This is used for hierarchy
  function addSystemRole(string _name, uint8 _weight) onlyOwner {
      require (!roleExists(_name));
      systemRoles[_name] = Role({
        name:_name,
        weight: _weight
      });
  }

  // @dev A shorthand function to add a role with no weight. This can be
  // used for systems where an exact role is required, with no hierarchy.
  // @param _name - the name of the new role
  function addZeroWeightSystemRole(string _name) onlyOwner {
    addSystemRole(_name,0);
  }

  function changeRoleWeight(string _name, uint8 _newWeight) {
    require (roleExists(_name));
    systemRoles[_name].weight = _newWeight;
  }

  // @dev Adds a role to a user
  // If the user already has the role - it will not be added again.
  // @param _user - the address to add the role to
  // @param _role - the name of the role to add to the user
  function addRoleToUser(address _user, string _role) onlyOwner {
    require(roleExists(_role));
    if (!userInRole(_user, _role)) {
      userRoles[_user].push(systemRoles[_role]);
    }
  }

  // @dev remove a role from user
  // @param _user - the address to remove the role from
  // @param _role - the name of the role to remove
  function removeRoleFromUser(address _user, string _role) onlyOwner {
    require(roleExists(_role));
    var numRolesForUser = userRoles[_user].length;
    if (numRolesForUser!=0) {
      for (uint i = 0 ; i < userRoles[_user].length; i++) {
        if (sha3(userRoles[_user][i].name) == sha3(_role)) {
          userRoles[_user][i] = userRoles[_user][numRolesForUser-1];
          userRoles[_user].length--;
        }
      }
    }
  }

  // @dev Checks whether the user has a specific role
  // @param _user - the address to check the role for
  // @param _roleName - the role to check for
  // @return bool - whether the user has the role assigned to them or not
  function userInExactRole(address _user, string _roleName) constant returns (bool) {
    for (uint i = 0 ; i < userRoles[_user].length; i++) {
      if (sha3(userRoles[_user][i].name) == sha3(_roleName)) {
        return true;
      }
    }
    return false;
  }

  // @dev Checks whether a specific user has a role assigned, or - they have
  // a higher weight role assigned to them.
  // @param _user - the address to check the role for
  // @param _roleName - the role to check for
  // @return bool - whether the user has the either the exact role or a higher weight
  // role assigned to them or not
  function userInRole(address _user, string _roleName) constant returns (bool) {
    require(roleExists(_roleName));
    for (uint i = 0 ; i < userRoles[_user].length; i++) {
      if ( (userRoles[_user][i].weight > systemRoles[_roleName].weight) ||
           (sha3(userRoles[_user][i].name) == sha3(_roleName)) ) {
        return true;
      }
    }
    return false;
  }

  // @dev Checks whether a role exists in the system.
  // @param _name - the name to check.
  // @return bool - whether the role is registered in the system or not
  function roleExists(string _name) constant returns (bool) {
    require(bytes(_name).length > 0);
    return bytes(systemRoles[_name].name).length!=0;
  }
}
