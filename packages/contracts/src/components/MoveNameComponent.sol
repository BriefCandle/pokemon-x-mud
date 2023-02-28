// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { StringComponent } from "std-contracts/components/StringComponent.sol";

uint256 constant ID = uint256(keccak256("component.MoveName"));

// because move, different from pokemon, has no index as source of truth
contract MoveNameComponent is StringComponent {
  constructor(address world) StringComponent(world, ID) {}
}
