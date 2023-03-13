// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { PokemonType } from "../PokemonType.sol";
import { MoveCategory } from "../MoveCategory.sol";

// teamID -> Team struct {}
// Note: CANNOT do teamID -> memberID because member has placement order
// each member is a pokemonInstance ID
struct TeamPokemons {
  uint256 member0;
  uint256 member1;
  uint256 member2;
  uint256 member3;
  uint256 member4;
  uint256 member5;
}

uint256 constant ID = uint256(keccak256("component.TeamPokemons"));

contract TeamPokemonsComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](6);
    values = new LibTypes.SchemaValue[](6);

    keys[0] = "member0";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "member1";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "member2";
    values[2] = LibTypes.SchemaValue.UINT256;

    keys[3] = "member3";
    values[3] = LibTypes.SchemaValue.UINT256;

    keys[4] = "member4";
    values[4] = LibTypes.SchemaValue.UINT256;

    keys[5] = "member5";
    values[5] = LibTypes.SchemaValue.UINT256;
  }

  function set(uint256 entity, TeamPokemons calldata pokemons) public virtual {
    set(entity, abi.encode(pokemons));
  }

  function getValue(uint256 entity) public view virtual returns (TeamPokemons memory pokemons) {
    pokemons = abi.decode(getRawValue(entity), (TeamPokemons));
  }
}