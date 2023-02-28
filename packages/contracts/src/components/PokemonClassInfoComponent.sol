// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { PokemonType } from "../PokemonType.sol";
import { LevelRate } from "../LevelRate.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { StatusCondition } from "../StatusCondition.sol";
 
struct PokemonClassInfo {
    uint32 catchRate;
    PokemonType type1;
    PokemonType type2;
    LevelRate levelRate;
}

uint256 constant ID = uint256(keccak256("component.PokemonClassInfo"));

contract PokemonClassInfoComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](4);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "catchRate";
    values[0] = LibTypes.SchemaValue.UINT32;

    keys[1] = "type1";
    values[1] = LibTypes.SchemaValue.UINT8;

    keys[2] = "type2";
    values[2] = LibTypes.SchemaValue.UINT8;

    keys[3] = "levelRate";
    values[3] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, PokemonClassInfo calldata info) public virtual {
    set(entity, abi.encode(info));
  }

  function getValue(uint256 entity) public view virtual returns (PokemonClassInfo memory info) {
    info = abi.decode(getRawValue(entity), (PokemonClassInfo));
  }
}