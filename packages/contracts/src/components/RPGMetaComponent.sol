// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";

struct RPGMeta {
  string name;
  string description;
  string url;
  string others; //whatever other meta data is saved here
}

abstract contract RPGMetaComponent is Component {
  constructor(address world, uint256 ID) Component(world, ID) {}

  function getSchema() public pure returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](4);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "name";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "description";
    values[1] = LibTypes.SchemaValue.STRING;

    keys[2] = "url";
    values[2] = LibTypes.SchemaValue.STRING;

    keys[3] = "others";
    values[3] = LibTypes.SchemaValue.STRING;

  }

  function set(uint256 entity, RPGMeta memory meta) public {
    set(entity, abi.encode(meta.name, meta.description, meta.url, meta.others));
  }

  function getValue(uint256 entity) public view returns (RPGMeta memory) {
    (string memory name, string memory description, string memory url, string memory others) = abi
    .decode(getRawValue(entity), (string, string, string, string));
    
    return RPGMeta(name, description, url, others);
  }
}