// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { RPGMetaComponent, RPGMeta } from "./RPGMetaComponent.sol";

uint256 constant ID = uint256(keccak256("component.ClassHeroMeta"));

contract ClassHeroMetaComponent is RPGMetaComponent {
  constructor(address world) RPGMetaComponent(world, ID) {}

}
