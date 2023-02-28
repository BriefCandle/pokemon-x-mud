// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { PokemonType } from "../PokemonType.sol";
import { MoveCategory } from "../MoveCategory.sol";

struct MoveInfo {
    PokemonType TYP; // move type
    MoveCategory CTG; // move category
    uint8 PP;
    uint8 PWR; // power
    uint8 ACR; // accuracy
}

uint256 constant ID = uint256(keccak256("component.MoveInfo"));

contract MoveInfoComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](5);
    values = new LibTypes.SchemaValue[](5);

    keys[0] = "TYP";
    values[0] = LibTypes.SchemaValue.UINT8;

    keys[1] = "CTG";
    values[1] = LibTypes.SchemaValue.UINT8;

    keys[2] = "PP";
    values[2] = LibTypes.SchemaValue.UINT8;

    keys[3] = "PWR";
    values[3] = LibTypes.SchemaValue.UINT8;

    keys[4] = "ACR";
    values[4] = LibTypes.SchemaValue.UINT8;
  }

  function set(uint256 entity, MoveInfo calldata stats) public virtual {
    set(entity, abi.encode(stats));
  }

  function getValue(uint256 entity) public view virtual returns (MoveInfo memory stats) {
    stats = abi.decode(getRawValue(entity), (MoveInfo));
  }
}