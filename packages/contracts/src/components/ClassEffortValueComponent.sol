// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { PokemonStatsComponent, PokemonStats } from "./PokemonStatsComponent.sol";

uint256 constant ID = uint256(keccak256("component.ClassEffortValue"));

//---- inherent to a pokemon class ----
contract ClassEffortValueComponent is PokemonStatsComponent {
  constructor(address world) PokemonStatsComponent(world, ID) {}

}
