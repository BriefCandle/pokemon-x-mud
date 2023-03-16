// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";
import { BattleActionType } from "../BattleActionType.sol";

uint256 constant ID = uint256(keccak256("component.RNGActionType"));

contract RNGActionTypeComponent is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}

  function set(uint256 entity, BattleActionType value) public {
    set(entity, abi.encode(value));
  }

  function getValueTyped(uint256 entity) public view returns (BattleActionType) {
    return abi.decode(getRawValue(entity), (BattleActionType));
  }
}
