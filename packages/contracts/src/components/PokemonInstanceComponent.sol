// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { StatusCondition } from "../StatusCondition.sol";

// this is not exclusive of all pokemon instance data
// also need to include nickname and IV
// additional battle instance needs to be created during battle
struct PokemonInstance {
  uint256 classID;
  uint256 move1;
  uint256 move2;
  uint256 move3;
  uint256 move4;
  uint256 heldItem;
  uint32 exp;
  uint32 currentHP;
  StatusCondition sc;
}

uint256 constant ID = uint256(keccak256("component.PokemonInstance"));

contract PokemonInstanceComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](9);
    values = new LibTypes.SchemaValue[](9);

    keys[0] = "classID";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "move1";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "move2";
    values[2] = LibTypes.SchemaValue.UINT256;

    keys[3] = "move3";
    values[3] = LibTypes.SchemaValue.UINT256;

    keys[4] = "move4";
    values[4] = LibTypes.SchemaValue.UINT256;

    keys[5] = "heldItem";
    values[5] = LibTypes.SchemaValue.UINT256;

    keys[6] = "exp";
    values[6] = LibTypes.SchemaValue.UINT32;

    keys[7] = "currentHP";
    values[7] = LibTypes.SchemaValue.UINT32;

    keys[8] = "sc";
    values[8] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, PokemonInstance calldata instance) public virtual {
    set(entity, abi.encode(instance));
  }

  function getValue(uint256 entity) public view virtual returns (PokemonInstance memory instance) {
    instance = abi.decode(getRawValue(entity), (PokemonInstance));
  }
}