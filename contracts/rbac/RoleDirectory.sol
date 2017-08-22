pragma solidity ^0.4.11;

import '../ownership/Ownable.sol';

/**
 * @title SecurityControl
 * @dev A simple security centre to define roles and assign them to addresses
 * (users)
 *
 * A role is constructed of a unique name (within the SecurityControl) and a weight.
 * The weight of the role can be used by developers wanting to create a role
 * hierarchy. When the hasRole function is used, it will check that the clled has
 * either the exact role name, or a role that carries more weight.
 */
contract RoleDirectory is Ownable {

  struct Role {
    string name;
    uint8 weight;
  }

  mapping(string=>Role) private systemRoles;
  mapping(address=>Role[]) private userRoles;

  function addRoleToUser(address _user, string _role) onlyOwner {
    require(roleExists(_role));
    userRoles[_user].push(systemRoles[_role]);
  }

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

  //Used by the owner only to add a new role in the system.
  //The new role has to have a unique name.
  //@param _name - the name of the new role
  //@param _weight - weight to the role. This is used for hierarchy
  function addSystemRole(string _name, uint8 _weight) onlyOwner {
      require (!roleExists(_name));
      systemRoles[_name] = Role({
        name:_name,
        weight: _weight
      });
  }

  // A shorthand function to add a role with the lowest weight. This can be
  // used for systems where an exact role is required, with no hierarchy.
  function addSystemRole(string _name) onlyOwner {
    addSystemRole(_name,0);
  }

  function roleExists(string _name) constant returns (bool) {
    require(bytes(_name).length > 0);
    return bytes(systemRoles[_name].name).length!=0;
  }
}
