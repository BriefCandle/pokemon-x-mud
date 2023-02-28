// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { PokemonType } from "../PokemonType.sol";
import { MoveCategory } from "../MoveCategory.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { StatusCondition } from "../StatusCondition.sol";
 
struct MoveEffect {
    int8 HP; // health points
    int8 ATK; // attack; A
    int8 DEF; // defence; B
    int8 SPATK; // special attack; C
    int8 SPDEF; // special defence; D
    int8 SPD; // speed; S
    int8 CRT; // critical rate
    int8 ACC; // accuracy
    int8 EVA; // evasive
    uint8 chance; 
    uint8 duration; // duration is not for sc; 0 means across battle
    MoveTarget target;
    StatusCondition sc;
}

uint256 constant ID = uint256(keccak256("component.MoveEffect"));

contract MoveEffectComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](13);
    values = new LibTypes.SchemaValue[](13);

    keys[0] = "HP";
    values[0] = LibTypes.SchemaValue.INT8;

    keys[1] = "ATK";
    values[1] = LibTypes.SchemaValue.INT8;

    keys[2] = "DEF";
    values[2] = LibTypes.SchemaValue.INT8;

    keys[3] = "SPATK";
    values[3] = LibTypes.SchemaValue.INT8;

    keys[4] = "SPDEF";
    values[4] = LibTypes.SchemaValue.INT8;

    keys[5] = "SPD";
    values[5] = LibTypes.SchemaValue.INT8;

    keys[6] = "CRT";
    values[6] = LibTypes.SchemaValue.INT8;

    keys[7] = "ACC";
    values[7] = LibTypes.SchemaValue.INT8;

    keys[8] = "EVA";
    values[8] = LibTypes.SchemaValue.INT8;

    keys[9] = "chance";
    values[9] = LibTypes.SchemaValue.UINT8;
    
    keys[10] = "duration";
    values[10] = LibTypes.SchemaValue.UINT8;

    keys[11] = "target";
    values[11] = LibTypes.SchemaValue.UINT8;

    keys[12] = "sc";
    values[12] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, MoveEffect calldata effect) public virtual {
    set(entity, abi.encode(effect));
  }

  function getValue(uint256 entity) public view virtual returns (MoveEffect memory effect) {
    effect = abi.decode(getRawValue(entity), (MoveEffect));
  }
}