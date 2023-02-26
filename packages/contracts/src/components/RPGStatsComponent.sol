// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";

struct RPGStats {
    int32 MAXHLTH; // max health
    int32 DMG; // damage
    int32 SPD; // speed
    int32 PRT; // protection
    int32 CRT; // critical
    int32 ACR; // accuracy
    int32 DDG; // dodge
    int32 DRN; // duration; 
}

abstract contract RPGStatsComponent is Component {
  constructor(address world, uint256 ID) Component(world, ID) {}

  function getSchema() public pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](8);
    values = new LibTypes.SchemaValue[](8);

    keys[0] = "MAXHLTH";
    values[0] = LibTypes.SchemaValue.INT32;

    keys[1] = "DMG";
    values[1] = LibTypes.SchemaValue.INT32;

    keys[2] = "SPD";
    values[2] = LibTypes.SchemaValue.INT32;

    keys[3] = "PRT";
    values[3] = LibTypes.SchemaValue.INT32;

    keys[4] = "CRT";
    values[4] = LibTypes.SchemaValue.INT32;

    keys[5] = "ACR";
    values[5] = LibTypes.SchemaValue.INT32;

    keys[6] = "DDG";
    values[6] = LibTypes.SchemaValue.INT32;

    keys[7] = "DRN";
    values[7] = LibTypes.SchemaValue.INT32;
  }

  function set(uint256 entity, RPGStats calldata stats) public {
    set(entity, abi.encode(stats));
  }

  function getValue(uint256 entity) public view virtual returns (RPGStats memory stats) {
    stats = abi.decode(getRawValue(entity), (RPGStats));
  }
}