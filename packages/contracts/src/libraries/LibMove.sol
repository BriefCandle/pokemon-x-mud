// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { LibPokemon } from "./LibPokemon.sol";
import { LibPokemonClass } from "./LibPokemonClass.sol";
import { LibTeam } from "./LibTeam.sol";
import { LibBattle } from "./LibBattle.sol";

import { BattleStats } from "../components/PokemonBattleStatsComponent.sol";

import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";
import { PokemonClassInfo } from "../components/ClassInfoComponent.sol";

import { ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";
import { ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ID as PlayerComponentID } from "../components/PlayerComponent.sol";

library LibMove {

  function executeMove(IUint256Component components, uint256 attackerID, uint256 targetID, uint256 moveID, uint256 randomNumber) internal {
    // HP
    uint32 target_HP = LibPokemon.getHP(components, targetID);
    uint32 DMG = calculateMoveEffectOnHP(components, attackerID, targetID, moveID, randomNumber);
    target_HP = target_HP > DMG ? target_HP - DMG : 0;

    LibPokemon.setHP(components, targetID, target_HP);

    // other stats
    // BattleStats memory battleStats = calculateEffectOnBattleStats(components, attackerID, targetID, moveID, randomNumber);
    // LibPokemon.setBattleStats(components, targetID, battleStats);
  }


  // TODO: add duration / status condition
  function calculateEffectOnBattleStats(IUint256Component components, uint256 attackerID, uint256 targetID, uint256 moveID, uint256 randomNumber) 
  internal view returns (BattleStats memory battleStats) {
    MoveEffect memory moveEffect = LibMove.getMoveEffect(components, moveID);
    BattleStats memory target_stats = LibPokemon.getBattleStats(components, targetID);
    battleStats =  BattleStats(
        target_stats.ATK + moveEffect.ATK,
        target_stats.DEF + moveEffect.DEF,
        target_stats.SPATK + moveEffect.SPATK,
        target_stats.SPDEF + moveEffect.SPDEF,
        target_stats.SPD + moveEffect.SPD,
        target_stats.CRT + moveEffect.CRT,
        target_stats.ACC + moveEffect.ACC,
        target_stats.EVA + moveEffect.EVA,
        target_stats.duration
    );
  }

  function calculateMoveEffectOnHP(IUint256Component components, 
  uint256 attackerID, uint256 targetID, uint256 moveID, uint256 randomNumber) 
  internal view returns (uint32 DMG) {
    uint32 attacker_level = LibPokemon.getLevel(components, attackerID);
    PokemonStats memory attacker_stats = LibPokemon.getPokemonBattleStats(components, attackerID);
    uint16 target_DEF = LibPokemon.getPokemonBattleStats(components, targetID).DEF;
    // target class info
    uint256 target_classID = LibPokemon.getClassID(components, targetID);
    PokemonClassInfo memory target_class = LibPokemonClass.getClassInfo(components, target_classID);
    // move info and effect
    MoveInfo memory moveInfo = getMoveInfo(components, moveID);
    int8 moveEffect_CRT = getMoveEffect(components, moveID).CRT;
    // type effect
    uint8 effectValue = LibPokemon.getTotalEffectValue(moveInfo.TYP, target_class.type1, target_class.type2);
    bool isCrit = checkCritical(attacker_stats.SPD, moveEffect_CRT, randomNumber);
    uint32 critEffect = isCrit ? 2 : 1;
    // DMG
    uint32 DMG_part = (2 * attacker_level / 5 + 2) * uint32(moveInfo.PWR) 
      * uint32(attacker_stats.ATK) / uint32(target_DEF) / 50 + 2;
    DMG = DMG_part * uint32(effectValue) * critEffect;
  }

  // complicated to calculate crit chance for gen II onward
  // https://bulbapedia.bulbagarden.net/wiki/Critical_hit
  // use gen I for now
  function checkCritical(uint16 SPD, int8 CRT, uint256 randomNumber) internal pure returns (bool) {
    uint32 multiplier = LibPokemon.getStatsMultipled(CRT, 1);
    uint256 threshold = randomNumber % 256;
    return multiplier * SPD / 2 > threshold ? true : false;
  }

  function getMoveEffect(IUint256Component components, uint256 moveID) internal view returns (MoveEffect memory) {
    MoveEffectComponent moveEffect = MoveEffectComponent(getAddressById(components, MoveEffectComponentID));
    return moveEffect.getValue(moveID);
  }

  function getMoveInfo(IUint256Component components, uint256 moveID) internal view returns (MoveInfo memory) {
    MoveInfoComponent moveInfo = MoveInfoComponent(getAddressById(components, MoveInfoComponentID));
    return moveInfo.getValue(moveID);
  }
  
}