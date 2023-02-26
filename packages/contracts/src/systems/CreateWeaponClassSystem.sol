// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { RPGStats } from "components/RPGStatsComponent.sol";
import { ClassWeaponComponent, ID as ClassWeaponComponentID } from "components/ClassWeaponComponent.sol";

uint256 constant ID = uint256(keccak256("system.CreateWeaponClass"));

contract CreateWeaponClassSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 entityID, RPGStats memory stats) = abi.decode(args, (uint256, RPGStats));
    return executeTyped(entityID, stats);
  }

  function executeTyped(uint256 entityID, RPGStats memory stats) public returns (bytes memory) {
    ClassWeaponComponent weaponClass = ClassWeaponComponent(getAddressById(components, ClassWeaponComponentID));

    weaponClass.set(entityID, stats);
  }
}