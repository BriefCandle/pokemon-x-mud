// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.RPG.Stats.01"));

struct RPGStats01 {
    string name;
    string description;
    string external_link;
    string effect;
    int32 MAXHLTH; // max health
    int32 DMG; // damage
    int32 SPD; // speed
    int32 PRT; // protection
    int32 CRT; // critical
    int32 ACR; // accuracy
    int32 DDG; // dodge
    int32 DRN; // duration; 0 means permanent, 1 shall prompt deletion of stats
    // more stats can be added onto the list, 
    // such as different types of resistance
}

contract RPGStatsComponent01 is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](10);
    values = new LibTypes.SchemaValue[](10);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "description";
    values[1] = LibTypes.SchemaValue.STRING;

    keys[2] = "external_link";
    values[2] = LibTypes.SchemaValue.STRING;

    keys[3] = "effect";
    values[3] = LibTypes.SchemaValue.STRING;

    keys[4] = "MAXHLTH";
    values[4] = LibTypes.SchemaValue.INT32;

    keys[5] = "DMG";
    values[5] = LibTypes.SchemaValue.INT32;

    keys[6] = "SPD";
    values[6] = LibTypes.SchemaValue.INT32;

    keys[7] = "PRT";
    values[7] = LibTypes.SchemaValue.INT32;

    keys[8] = "CRT";
    values[8] = LibTypes.SchemaValue.INT32;

    keys[9] = "ACR";
    values[9] = LibTypes.SchemaValue.INT32;

    keys[10] = "DDG";
    values[10] = LibTypes.SchemaValue.INT32;

    keys[11] = "DRN";
    values[11] = LibTypes.SchemaValue.INT32;
  }

  function set(uint256 entity, RPGStats stats) public {
    set(entity, abi.encode(
      stats.name, stats.description, stats.external_link, stats.effect, stats.DMG,
      stats.SPD, stats.PRT, stats.CRT, stats.ACR, stats.DDG
    ));
  }

  function getValue(uint256 entity) public view returns (RPGStats memory) {
    (string name, string description, string external_link, string effect, int32 MAXHLTH,
      int32 DMG, int32 SPD, int32 PRT, int32 CRT, int32 ACR, int32 DDG, int32 DRN) = abi.decode(
      getRawValue(entity), 
      (string, string, string, string, int32, int32, int32, int32, int32, int32, int32, int32));
    return RPGStats(name, description, external_link, effect, MAXHLTH, DMG, SPD, PRT, CRT, ACR, DDG, DRN);
  }

}