// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";
import { PokemonType } from "../PokemonType.sol";

uint256 constant ID = uint256(keccak256("component.PokemonType1"));

//---- inherent to a pokemon class ----
// ideally, uint8
contract PokemonType1Component is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}

  function set(uint256 entity, PokemonType value) public {
    set(entity, abi.encode(value));
  }

  function getValueTyped(uint256 entity) public view returns (PokemonType) {
    return abi.decode(getRawValue(entity), (PokemonType));
  }
}