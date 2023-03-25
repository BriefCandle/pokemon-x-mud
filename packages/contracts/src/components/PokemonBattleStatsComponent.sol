// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";

struct BattleStats {
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

uint256 constant ID = uint256(keccak256("component.PokemonBattleStats"));

contract PokemonBattleStatsComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](9);
    values = new LibTypes.SchemaValue[](9);

    keys[0] = "ATK";
    values[0] = LibTypes.SchemaValue.INT8;

    keys[1] = "DEF";
    values[1] = LibTypes.SchemaValue.INT8;

    keys[2] = "SPATK";
    values[2] = LibTypes.SchemaValue.INT8;

    keys[3] = "SPDEF";
    values[3] = LibTypes.SchemaValue.INT8;

    keys[4] = "SPD";
    values[4] = LibTypes.SchemaValue.INT8;

    keys[5] = "CRT";
    values[5] = LibTypes.SchemaValue.INT8;

    keys[6] = "ACC";
    values[6] = LibTypes.SchemaValue.INT8;

    keys[7] = "EVA";
    values[7] = LibTypes.SchemaValue.INT8;
    
    keys[8] = "duration";
    values[8] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, BattleStats calldata instance) public virtual {
    set(entity, abi.encode(instance));
  }

  function getValue(uint256 entity) public view virtual returns (BattleStats memory instance) {
    instance = abi.decode(getRawValue(entity), (BattleStats));
  }
}