// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint256ArrayComponent } from "std-contracts/components/Uint256ArrayComponent.sol";

uint256 constant ID = uint256(keccak256("component.PokemonMoves"));

// pokemonID -> uint256[] moveIDs
contract PokemonMovesComponent is Uint256ArrayComponent {
  constructor(address world) Uint256ArrayComponent(world, ID) {}

}