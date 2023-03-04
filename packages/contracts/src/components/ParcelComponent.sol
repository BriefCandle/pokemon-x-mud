// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { PokemonType } from "../PokemonType.sol";

// a parcel is parcelWidth x parcelHeight
struct Parcel {
    int32 x; // x coordinate of parcel
    int32 y; // y coordinate of parcel
    bytes terrain; 
}

// would receive intrinsic gas too high error if parcel too large
uint32 constant parcelWidth = 5; 
uint32 constant parcelHeight = 5;

uint256 constant ID = uint256(keccak256("component.Parcel"));

contract ParcelComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3);
    values = new LibTypes.SchemaValue[](3);

    keys[0] = "x";
    values[0] = LibTypes.SchemaValue.INT32;

    keys[1] = "y";
    values[1] = LibTypes.SchemaValue.INT32;

    keys[2] = "terrain";
    values[2] = LibTypes.SchemaValue.STRING;
  }

  function set(uint256 entity, Parcel memory map) public virtual {
    set(entity, abi.encode(map.x, map.y, map.terrain));
  }

  function getValue(uint256 entity) public view virtual returns (Parcel memory) {
    (int32 x, int32 y, bytes memory terrain) = abi.decode(
      getRawValue(entity), (int32, int32, bytes));
    return Parcel(x, y, terrain);
  }
}