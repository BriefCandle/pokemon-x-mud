// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { RPGStatsComponent, RPGStats } from "./RPGStatsComponent.sol";

uint256 constant ID = uint256(keccak256("component.ClassHeroStats"));

contract ClassHeroStatsComponent is RPGStatsComponent {
  constructor(address world) RPGStatsComponent(world, ID) {}

}
