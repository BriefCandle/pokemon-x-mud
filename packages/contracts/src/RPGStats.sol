// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { LibTypes } from "solecs/LibTypes.sol";

contract RPGStats {

  struct Stats {
    string name;
    string description;
    string external_link;
    uint256 MAXHLTH; // max health
    int16 DMG; // damage
    int16 SPD; // speed
    int16 PRT; // protection
    int16 CRT; // critical
    int16 ACR; // accuracy
    int16 DDG; // dodge
    // more stats can be added onto the list, 
    // such as different types of resistance
  }

  function getSchema() public pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](10);
    values = new LibTypes.SchemaValue[](10);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "description";
    values[1] = LibTypes.SchemaValue.STRING;

    keys[2] = "external_link";
    values[2] = LibTypes.SchemaValue.STRING;

    keys[3] = "MAXHLTH";
    values[3] = LibTypes.SchemaValue.UINT256;

    keys[4] = "DMG";
    values[4] = LibTypes.SchemaValue.INT16;

    keys[5] = "SPD";
    values[5] = LibTypes.SchemaValue.INT16;

    keys[6] = "PRT";
    values[6] = LibTypes.SchemaValue.INT16;

    keys[7] = "CRT";
    values[7] = LibTypes.SchemaValue.INT16;

    keys[8] = "ACR";
    values[8] = LibTypes.SchemaValue.INT16;

    keys[9] = "DDG";
    values[9] = LibTypes.SchemaValue.INT16;
  }
}



