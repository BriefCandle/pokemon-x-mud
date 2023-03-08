// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";
import { BattleType } from "../BattleType.sol";

uint256 constant ID = uint256(keccak256("component.BattleType"));

// battleID -> enum BattleType:
contract BattleTypeComponent is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}

  function set(uint256 entity, BattleType value) public {
    set(entity, abi.encode(value));
  }

  function getValueTyped(uint256 entity) public view returns (BattleType) {
    return abi.decode(getRawValue(entity), (BattleType));
  }
}
