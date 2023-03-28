// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { BattleActionType } from "../BattleActionType.sol";

import { LibTeam } from "./LibTeam.sol";

import { RNGPrecommitComponent, ID as RNGPrecommitComponentID } from "../components/RNGPrecommitComponent.sol";
import { RNGActionTypeComponent, ID as RNGActionTypeComponentID } from "../components/RNGActionTypeComponent.sol";
import { RNGTargetComponent, ID as RNGTargetComponentID } from "../components/RNGTargetComponent.sol";

import { ID as BattleSystemID } from "../systems/BattleSystem.sol";

// many modification are made on original: 
// https://github.com/dk1a/wanderer-cycle/blob/master/packages/contracts/src/rng/LibRNG.sol
// because in pokemon battling:
// 1) each player has only one random number each time; 
// 2) before resolving, player can take NO action
// 3) random number is of different type, reflecting different game actions

// not using playerID because BattleSystem could manage multiple teams
// not using teamID to allow expansion beyong turn-based

library LibRNG {
  error LibRNG__nonExistPrecommit();
  error LibRNG__notExistActionType();
  error LibRNG__notExistTargetID();

  // TODO 0 wait allows 2 txs in a row really fast and is great during local dev, but not exactly safe
  // (note that this does not allow same-block retrieval - you can't get current blockhash)
  uint256 constant WAIT_BLOCKS = 0;

  function commit(IUint256Component components, uint256 pokemonID, BattleActionType actionType, uint256 targetID) internal {
    RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).set(
      pokemonID,
      block.number + WAIT_BLOCKS
    );
    RNGActionTypeComponent(getAddressById(components, RNGActionTypeComponentID)).set(
      pokemonID,
      actionType
    );
    RNGTargetComponent(getAddressById(components, RNGTargetComponentID)).set(
      pokemonID,
      targetID
    );
  }

  function reveal(IUint256Component components, uint256 pokemonID, uint256 targetID, BattleActionType action) internal returns (uint256 randomness) {
    if (!isExist(components, pokemonID)) revert LibRNG__nonExistPrecommit();
    if (action != BattleActionType.Skip && !isExistActionType(components, pokemonID, action)) revert LibRNG__notExistActionType();
    if (!isExistTargetID(components, pokemonID, targetID)) revert LibRNG__notExistTargetID();

    uint256 precommit = getPrecommit(components, pokemonID);
    _removePrecommit(components, pokemonID);

    if (!isValid(precommit)) {
      if (LibTeam.pokemonIDToPlayerID(components, pokemonID) == BattleSystemID) return 0;
      return 255;
    }
    
    return uint256(blockhash(precommit));
  }

  function _removePrecommit(IUint256Component components, uint256 pokemonID) private {
    RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).remove(pokemonID);
    RNGActionTypeComponent(getAddressById(components, RNGActionTypeComponentID)).remove(pokemonID);
    RNGTargetComponent(getAddressById(components, RNGTargetComponentID)).remove(pokemonID);

  }

  // called when precommit exist 
  function getPrecommit(IUint256Component components, uint256 pokemonID) internal view returns (uint256 precommit) {
    return RNGPrecommitComponent(getAddressById(components, RNGPrecommitComponentID)).getValue(pokemonID);
  }

  // called when precommit exist 
  function getActionType(IUint256Component components, uint256 pokemonID) internal view returns (BattleActionType actionType) {
    return RNGActionTypeComponent(
      getAddressById(components, RNGActionTypeComponentID)).getValueTyped(pokemonID);
  }

  function getTargetID(IUint256Component components, uint256 pokemonID) internal view returns (uint256 targetID) {
    return RNGTargetComponent(
      getAddressById(components, RNGTargetComponentID)).getValue(pokemonID);
  }

  function isExist(IUint256Component components, uint256 pokemonID) internal view returns (bool) {
    return RNGPrecommitComponent(
      getAddressById(components, RNGPrecommitComponentID)).has(pokemonID) ? true : false;
  }

  function isExistActionType(IUint256Component components, uint256 pokemonID, BattleActionType action) internal view returns (bool) {
    if (isExist(components, pokemonID)) {
      return getActionType(components, pokemonID) == action ? true : false;
    } else return false;
  }

  function isExistTargetID(IUint256Component components, uint256 pokemonID, uint256 targetID) internal view returns(bool) {
    if (isExist(components, pokemonID)) {
      return getTargetID(components, pokemonID) == targetID ? true : false;
    } else return false;
  }

  function isValid(uint256 precommit) internal view returns (bool) {
    return
      // past the precommitted-to-block
      isPassWaitBlock(precommit) &&
      // and not too far past it because blockhash only works for 256 most recent blocks
      !isOverBlockLimit(precommit);
  }

  function isOverBlockLimit(uint256 precommit) internal view returns (bool) {
    return block.number > precommit + 256;
  }

  function isPassWaitBlock(uint256 precommit) internal view returns (bool) {
    return precommit < block.number;
  }
}