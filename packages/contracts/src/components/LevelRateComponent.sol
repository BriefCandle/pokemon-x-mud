// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";
import { LevelRate } from "../LevelRate.sol";

uint256 constant ID = uint256(keccak256("component.LevelRate"));

//---- inherent to a pokemon class ----
// ideally, uint8
contract LevelRateComponent is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}

  function set(uint256 entity, LevelRate value) public {
    set(entity, abi.encode(value));
  }

  function getValueTyped(uint256 entity) public view returns (LevelRate) {
    return abi.decode(getRawValue(entity), (LevelRate));
  }
}