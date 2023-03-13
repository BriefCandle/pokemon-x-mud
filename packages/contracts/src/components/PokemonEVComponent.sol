// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { PokemonStatsComponent, PokemonStats } from "./PokemonStatsComponent.sol";

uint256 constant ID = uint256(keccak256("component.PokemonEV"));

//---- inherent to a pokemon class ----
contract PokemonEVComponent is PokemonStatsComponent {
  constructor(address world) PokemonStatsComponent(world, ID) {}

}
