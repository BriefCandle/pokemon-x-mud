// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { StatusCondition } from "../StatusCondition.sol";

// this is not exclusive of all pokemon instance data
// also need to include nickname and IV
// TODO: break it down into individual components
// InstPokemonClassID (uint256), InstPokemonExp (uint32), IPokemonLevel (uint32), 
// InstPokemonMoves (uint256[]), IPokemonHP (uint32), IPokemonHeldItem (uint256),
// InstPokemonBattleStats (BattleStats), IPokemonStatus (uint32)
struct PokemonInstance {
  uint256 classID;
  uint256 move0;
  uint256 move1;
  uint256 move2;
  uint256 move3;
  uint256 heldItem;
  uint32 exp;
  uint8 level;
  uint32 currentHP;
  StatusCondition sc;
// include the following data here
    int8 ATK; // attack; A
    int8 DEF; // defence; B
    int8 SPATK; // special attack; C
    int8 SPDEF; // special defence; D
    int8 SPD; // speed; S
    int8 CRT; // critical rate
    int8 ACC; // accuracy
    int8 EVA; // evasive
    uint8 duration; 
}

uint256 constant ID = uint256(keccak256("component.PokemonInstance"));

contract PokemonInstanceComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](19);
    values = new LibTypes.SchemaValue[](19);

    keys[0] = "classID";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "move0";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "move1";
    values[2] = LibTypes.SchemaValue.UINT256;

    keys[3] = "move2";
    values[3] = LibTypes.SchemaValue.UINT256;

    keys[4] = "move3";
    values[4] = LibTypes.SchemaValue.UINT256;

    keys[5] = "heldItem";
    values[5] = LibTypes.SchemaValue.UINT256;

    keys[6] = "exp";
    values[6] = LibTypes.SchemaValue.UINT32;

    keys[7] = "level";
    values[7] = LibTypes.SchemaValue.UINT8;

    keys[8] = "currentHP";
    values[8] = LibTypes.SchemaValue.UINT32;

    keys[9] = "sc";
    values[9] = LibTypes.SchemaValue.UINT8;

    keys[10] = "ATK";
    values[10] = LibTypes.SchemaValue.INT8;

    keys[11] = "DEF";
    values[11] = LibTypes.SchemaValue.INT8;

    keys[12] = "SPATK";
    values[12] = LibTypes.SchemaValue.INT8;

    keys[13] = "SPDEF";
    values[13] = LibTypes.SchemaValue.INT8;

    keys[14] = "SPD";
    values[14] = LibTypes.SchemaValue.INT8;

    keys[15] = "CRT";
    values[15] = LibTypes.SchemaValue.INT8;

    keys[16] = "ACC";
    values[16] = LibTypes.SchemaValue.INT8;

    keys[17] = "EVA";
    values[17] = LibTypes.SchemaValue.INT8;
    
    keys[18] = "duration";
    values[18] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, PokemonInstance calldata instance) public virtual {
    set(entity, abi.encode(instance));
  }

  function getValue(uint256 entity) public view virtual returns (PokemonInstance memory instance) {
    instance = abi.decode(getRawValue(entity), (PokemonInstance));
  }
}