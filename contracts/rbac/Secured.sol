pragma solidity ^0.4.11;

import './RoleDirectory.sol';
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
contract Secured {

  RoleDirectory public roleDirectory;

  /**
   * @dev The Secured constructor sets the role directory to be used
   */
  function Secured(RoleDirectory _roleDirectory) {
    roleDirectory = _roleDirectory;
  }

  /**
   * @dev throws if the caller does not have the role or a higher weight role
   * assigned to them.
   */
  modifier hasRole(string _role) {
    require(roleDirectory.userInRole(msg.sender, _role));
    _;
  }

}
