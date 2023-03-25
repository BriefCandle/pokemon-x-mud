// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";

import { Uint256ArrayComponent } from "std-contracts/components/Uint256ArrayComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.BattlePokemons"));

// battleID -> pokemonID[]
contract BattlePokemonsComponent is Uint256ArrayComponent {
  constructor(address world) Uint256ArrayComponent(world, ID) {}
}