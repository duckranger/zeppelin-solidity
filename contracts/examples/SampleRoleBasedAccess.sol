pragma solidity ^0.4.11;

import "../rbac/Secured.sol";
import "../rbac/RoleDirectory.sol";


/**
 * @title SampleRoleBasedAccess
 * @dev An example of a contract using the Role Based Access Control capability
 */
contract SampleRoleBasedAccess is Secured {

  string public safe;
  address public lastModifier;

  function SampleRoleBasedAccess(RoleDirectory _roleDirectory) Secured(_roleDirectory) {
  }

  function allowAnyone(string _val ) {
      safe = _val;
      lastModifier = msg.sender;
  }

  function onlyAdmin(string _val) hasRole('admin') {
    safe = _val;
    lastModifier = msg.sender;
  }

  function operatorAndAdmin(string _val) hasRole('operator') {
    safe = _val;
    lastModifier = msg.sender;
  }
}
