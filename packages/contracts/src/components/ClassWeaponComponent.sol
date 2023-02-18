// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { RPGStatsComponent01, RPGStats01 } from "./RPGStatsComponent01.sol";

uint256 constant ID = uint256(keccak256("component.Class.Weapon"));

contract ClassWeaponComponent is RPGStatsComponent01 {
  constructor(address world) RPGStatsComponent01(world, ID) {}

}
