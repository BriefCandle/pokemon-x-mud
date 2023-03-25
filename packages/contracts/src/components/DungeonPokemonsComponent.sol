// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";

import { Uint32ArrayComponent } from "std-contracts/components/Uint32ArrayComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.DungeonPokemons"));

// parcelID -> pokemonID[]
contract DungeonPokemonsComponent is Uint32ArrayComponent {
  constructor(address world) Uint32ArrayComponent(world, ID) {}
}