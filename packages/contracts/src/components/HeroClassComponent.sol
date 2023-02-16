// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { RPGStatsComponent } from "./RPGStatsComponent.sol";
import { RPGStats } from "../RPGStats.sol";

uint256 constant ID = uint256(keccak256("component.Hero.Class"));

contract HeroClassComponent is RPGStatsComponent {
  constructor(address world) RPGStatsComponent(world, ID) {}

}
