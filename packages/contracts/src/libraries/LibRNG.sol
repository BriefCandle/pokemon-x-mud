// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { BattleActionType } from "../BattleActionType.sol";

import { RNGPrecommitComponent, ID as RNGPrecommitComponentID } from "../components/RNGPrecommitComponent.sol";
import { RNGActionTypeComponent, ID as RNGActionTypeComponentID } from "../components/RNGActionTypeComponent.sol";

// many modification are made on original: 
// https://github.com/dk1a/wanderer-cycle/blob/master/packages/contracts/src/rng/LibRNG.sol
// because in pokemon battling:
// 1) each player has only one random number each time; 
// 2) before resolving, player can take NO action
// 3) random number is of different type, reflecting different game actions

library LibRNG {
  error LibRNG__nonExistPrecommit();

  // TODO 0 wait allows 2 txs in a row really fast and is great during local dev, but not exactly safe
  // (note that this does not allow same-block retrieval - you can't get current blockhash)
  uint256 constant WAIT_BLOCKS = 0;

  function requestRandomness(IUint256Component components, uint256 playerID, BattleActionType actionType) internal {
    RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).set(
      playerID,
      block.number + WAIT_BLOCKS
    );
    RNGActionTypeComponent(getAddressById(components, RNGActionTypeComponentID)).set(
      playerID,
      actionType
    );
  }

  // called when precommit exist 
  function getRandomness(IUint256Component components, uint256 playerID) internal view returns (uint256 randomness) {
    // if (isExist(precommit)) revert LibRNG__nonExistPrecommit();
    uint256 precommit = getPrecommit(components, playerID);
    if (!isValid(precommit)) return 0;
    return uint256(blockhash(precommit));
  }

  // called when precommit exist 
  function removeRequest(IUint256Component components, uint256 playerID) internal {
    RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).remove(playerID);
    RNGActionTypeComponent(getAddressById(components, RNGActionTypeComponentID)).remove(playerID);
  }

  // called when precommit exist 
  function getPrecommit(IUint256Component components, uint256 playerID) internal view returns (uint256 precommit) {
    return RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).getValue(playerID);
  }

  // called when precommit exist 
  function getActionType(IUint256Component components, uint256 playerID) internal view returns (BattleActionType actionType) {
    return RNGActionTypeComponent(
      getAddressById(components, RNGActionTypeComponentID)).getValueTyped(playerID);
  }

  function isExist(IUint256Component components, uint256 playerID) internal view returns (bool) {
    return RNGActionTypeComponent(
      getAddressById(components, RNGActionTypeComponentID)).has(playerID) ? true : false;
  }

  function isValid(uint256 precommit) internal view returns (bool) {
    return
      // past the precommitted-to-block
      precommit < block.number &&
      // and not too far past it because blockhash only works for 256 most recent blocks
      !isOverBlockLimit(precommit);
  }

  function isOverBlockLimit(uint256 precommit) internal view returns (bool) {
    return block.number > precommit + 256;
  }
}