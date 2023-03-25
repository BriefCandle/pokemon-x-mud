// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";

import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { MoveTarget } from "../MoveTarget.sol";


import {LibPokemon} from "./LibPokemon.sol";
import { LibBattle } from "./LibBattle.sol";
import { LibMove } from "./LibMove.sol";
import { LibRNG } from "./LibRNG.sol";

library LibAction {

  error LibAction__ActionNotAvailableForBattleType();

  // false only if UsePokeball or Escape is used in battle against OtherPlayer and NPC
  function requireActionAvailable(IUint256Component components, uint256 battleID, BattleActionType action) internal view returns (bool) {
    BattleType battleType = LibBattle.getBattleType(components, battleID);
    if ((battleType == BattleType.OtherPlayer || battleType == BattleType.NPC) &&
        (action == BattleActionType.UsePokeball || action == BattleActionType.Escape) ) {
      revert LibAction__ActionNotAvailableForBattleType();
    } else return true;
  }

  function isActionMove(BattleActionType action) internal pure returns(bool) {
    return action == BattleActionType.Move0 || 
          action == BattleActionType.Move1 || 
          action == BattleActionType.Move2 || 
          action == BattleActionType.Move3 ? true: false;
  }

  function actionToMoveNumber(BattleActionType action) internal pure returns (uint8) {
    require(isActionMove(action));
    if (action == BattleActionType.Move0) return 0;
    if (action == BattleActionType.Move1) return 1;
    if (action == BattleActionType.Move2) return 2;
    else return 3;
  }



}