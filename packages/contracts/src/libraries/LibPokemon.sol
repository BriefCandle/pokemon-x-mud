// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { BaseStatsComponent, ID as BaseStatsComponentID, PokemonStats } from "../components/BaseStatsComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { PokemonClassInfoComponent, ID as PokemonClassInfoComponentID, PokemonClassInfo } from "../components/PokemonClassInfoComponent.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";
import { EffortValueComponent, ID as EffortValueComponentID } from "../components/EffortValueComponent.sol";
import { PokemonEVComponent, ID as PokemonEVComponentID } from "../components/PokemonEVComponent.sol";

import { MoveLevelPokemonComponent, ID as MoveLevelPokemonComponentID } from "../components/MoveLevelPokemonComponent.sol";

import { LevelRate } from "../LevelRate.sol";
import { TypeEffective } from "../TypeEffective.sol";
import { PokemonType } from "../PokemonType.sol";
import { BattleActionType } from "../BattleActionType.sol";

library LibPokemon {

  // NOTE: neither IV, nor nature is included in this Gen III calculation
  // NOTE: HP returned is the MAX HP, not current HP
  function getPokemonInstanceStats(IUint256Component components, uint256 pokemonID) internal view returns(PokemonStats memory) {
    // exp & classID -> baseStats
    PokemonInstance memory pokemonIns = getPokemonInstance(components, pokemonID);
    (uint256 classID, uint8 level) = (pokemonIns.classID, pokemonIns.level);
    BaseStatsComponent baseStats = BaseStatsComponent(getAddressById(components, BaseStatsComponentID));
    PokemonStats memory base = baseStats.getValue(classID);
    // EV
    PokemonEVComponent EV = PokemonEVComponent(getAddressById(components, PokemonEVComponentID));
    PokemonStats memory ev = EV.getValue(pokemonID);
    uint32 HP = (2 * uint32(base.HP) + uint32(ev.HP)/4) * uint32(level) / 100 + uint32(level) + 10;
    uint32 ATK = (2 * uint32(base.ATK) + uint32(ev.ATK)/4) * uint32(level) / 100 + 5;
    uint32 DEF = (2 * uint32(base.DEF) + uint32(ev.DEF)/4) * uint32(level) / 100 + 5;
    uint32 SPATK = (2 * uint32(base.SPATK) + uint32(ev.SPATK)/4) * uint32(level) / 100 + 5;
    uint32 SPDEF = (2 * uint32(base.SPDEF) + uint32(ev.SPDEF)/4) * uint32(level) / 100 + 5;
    uint32 SPD = (2 * uint32(base.SPD) + uint32(ev.SPD)/4) * uint32(level) / 100 + 5;
    return PokemonStats(uint8(HP), uint8(ATK), uint8(DEF), uint8(SPATK), uint8(SPDEF), uint8(SPD));
  }

  // the pokemon stats that should be used in battle
  function getPokemonBattleStats(IUint256Component components, uint256 pokemonID) internal view returns(PokemonStats memory) {
    // exp & classID -> baseStats
    PokemonInstance memory pokemonIns = getPokemonInstance(components, pokemonID);
    (uint256 classID, uint8 level, uint32 currentHP) = (pokemonIns.classID, pokemonIns.level, pokemonIns.currentHP);
    BaseStatsComponent baseStats = BaseStatsComponent(getAddressById(components, BaseStatsComponentID));
    PokemonStats memory base = baseStats.getValue(classID);
    // EV
    PokemonEVComponent EV = PokemonEVComponent(getAddressById(components, PokemonEVComponentID));
    PokemonStats memory ev = EV.getValue(pokemonID);
    uint32 ATK = (2 * uint32(base.ATK) + uint32(ev.ATK)/4) * uint32(level) / 100 + 5;
    uint32 DEF = (2 * uint32(base.DEF) + uint32(ev.DEF)/4) * uint32(level) / 100 + 5;
    uint32 SPATK = (2 * uint32(base.SPATK) + uint32(ev.SPATK)/4) * uint32(level) / 100 + 5;
    uint32 SPDEF = (2 * uint32(base.SPDEF) + uint32(ev.SPDEF)/4) * uint32(level) / 100 + 5;
    uint32 SPD = (2 * uint32(base.SPD) + uint32(ev.SPD)/4) * uint32(level) / 100 + 5;
    // add multiplier from pokemon instance
    return PokemonStats(uint8(currentHP), 
      uint8(getStatsMultipled(pokemonIns.ATK, ATK)), 
      uint8(getStatsMultipled(pokemonIns.DEF, DEF)), 
      uint8(getStatsMultipled(pokemonIns.SPATK, SPATK)), 
      uint8(getStatsMultipled(pokemonIns.SPDEF, SPDEF)), 
      uint8(getStatsMultipled(pokemonIns.SPD, SPD)));
  }

  function getStatsMultipled(int8 stage, uint32 stat) internal pure returns (uint32) {
    if (stage >= 0 ) {
      return stat * (uint32(uint8(stage)) + 2) / 2;
    } else {
      return stat * 2 / (uint32(uint8(-stage)) + 2);
    }
  }

  function pokemonIndexToClassID(IUint256Component components, uint32 index) internal view returns (uint256 classID) {
    PokemonIndexComponent pokemonIndex = PokemonIndexComponent(getAddressById(components, PokemonIndexComponentID));
    classID = pokemonIndex.getEntitiesWithValue(index)[0];
  }

  function getPokemonClassInfo(IUint256Component components, uint256 pokemonID) internal view returns(PokemonClassInfo memory) {
    PokemonInstance memory pokemonIns = getPokemonInstance(components, pokemonID);
    uint256 classID = pokemonIns.classID;
    PokemonClassInfoComponent classInfo = PokemonClassInfoComponent(getAddressById(components, PokemonClassInfoComponentID));
    return classInfo.getValue(classID);
  }

  function getPokemonInstance(IUint256Component components, uint256 pokemonID) internal view returns (PokemonInstance memory) {
    PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
    return pokemonInstance.getValue(pokemonID);
  }

  function getPokemonMoveID(IUint256Component components, uint256 pokemonID, uint8 moveNumber) internal view returns (uint256 moveID) {
    PokemonInstance memory instance = getPokemonInstance(components, pokemonID);
    return moveNumberToMoveID(instance, moveNumber);
  }

  function moveNumberToMoveID(PokemonInstance memory instance, uint8 moveNumber) internal pure returns (uint256 moveID) {
    if (moveNumber == 0) return instance.move0;
    else if (moveNumber == 1) return instance.move1;
    else if (moveNumber == 2) return instance.move2;
    else return instance.move3;
  }

  function moveTypeToMoveNumber(BattleActionType moveType) internal pure returns (uint8 moveNumber) {
    if (moveType == BattleActionType.Move0) return 0;
    else if (moveType == BattleActionType.Move1) return 1;
    else if (moveType == BattleActionType.Move2) return 2;
    else if (moveType == BattleActionType.Move3) return 3;
    else revert("not move type");
  }

  // TODO: implement a method to get the last four nonzero moves from movelLevel array according to level
  function getDefaultMoves(IUint256Component components, uint256 pokemonClassID, uint8 level) internal view returns (uint256[4] memory moves) {
    MoveLevelPokemonComponent moveLevelC = MoveLevelPokemonComponent(getAddressById(components, MoveLevelPokemonComponentID));
    uint256[] memory moveLevel = moveLevelC.getValue(pokemonClassID);
    // a temporary solution for now....
    moves[0] = moveLevel[0];
    moves[1] = moveLevel[1];
  }

  // calculate exp required to reach certain level
  // NOTE: the reason why there is no expToLevel is due to 
  // difficulty to perform square root
  function levelToExp(LevelRate levelRate, uint8 level) internal pure returns (uint32 exp) {
    // based on levelRate, convert exp to leve
    if (levelRate == LevelRate.Fast) 
      exp = 4* uint32(level)**3 /5;
    else if (levelRate == LevelRate.MediumFast) 
      exp = uint32(level)**3;
    else if (levelRate == LevelRate.MediumSlow) 
      exp = uint32(level)**3 / 5 * 6  + 100*uint32(level)- 140- 15 * uint32(level)**2;
    else exp = 5 * uint32(level)**3 / 4;
  }

  // calculate new level and exp after pokemon receives exp from defeating pokemon
  function getNewLevelAndExp(IUint256Component componentN, uint256 pokemonID, uint32 expAdd) internal view returns (uint8 levelNew, uint32 expNew) {
    // get pokemon instance value
    PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(componentN, PokemonInstanceComponentID));
    PokemonInstance memory pokemonIns = pokemonInstance.getValue(pokemonID);
    (uint256 classID, uint32 exp, uint8 level ) = (pokemonIns.classID, pokemonIns.exp, pokemonIns.level);
    // get pokemon class info
    PokemonClassInfoComponent classInfo = PokemonClassInfoComponent(getAddressById(componentN, PokemonClassInfoComponentID));
    LevelRate levelRate = classInfo.getValue(classID).levelRate;
    // calculate needed exp to reach next level
    uint32 expNeed = levelToExp(levelRate, level+1);
    if (expNeed <= exp + expAdd) {
      levelNew = level+1; 
      expNew = exp + expAdd - expNeed;
    } else {
      levelNew = level;
      expNew = exp + expAdd;
    }
  }

  // calculate exp gained from defeating pokemonID
  function getExpGained(IUint256Component componentN, uint256 pokemonID) internal view returns (uint32 exp) {
    exp = 0;
  }

  /**
   * 
   * @param type1: type of attacking pokemon
   * @param type2: type of defending pokemon
   */
  // NOTE: type1 attackN, type2 defends
  function getTypeEffective(PokemonType type1, PokemonType type2) internal pure returns (TypeEffective effect) {
    TypeEffective I = TypeEffective.Immune;
    TypeEffective O = TypeEffective.NotVery;
    TypeEffective N = TypeEffective.Normal;
    TypeEffective S = TypeEffective.Super;
    TypeEffective[17][17] memory typeChart = [
      [N, N, N, N, N, O, N, I, O, N, S ,N, N, N, N, N, N],
      [S, N, O, O, N, S, O, I, S, N, N, N, N, O, S, N, S],
      [N, S, N, N, N, O, S, N, O, N, N, S, O, N, N, N, N],
      [N, N, N, O, O, O, N, O, I, N, N, S, N, N, N, N, N],
      [N, N, I, S, N, S, O, N, S, S, N, O, S, N, N, N, N],
      [N, O, S, N, O, N, S, N, O, S, N, N, N, N, S, N, N],
      [N, O, O, O, N, N, N, O, O, O, N, S, N, S, N, N, S],
      [I, N, N, N, N, N, N, S, N, N, N, N, N, S, N, N, O],
      [N, N, N, N, N, S, N, N, O, O, O, N, O, N, S, N, N],
      [N, N, N, N, N, O, S, N, S, O, O, S, N, N, S, O, N],
      [N, N, N, N, S, S, N, N, N, S, O, O, N, N, N, O, N],
      [N, N, O, O, S, S, O, N, O, O, S, O, N, N, N, O, N],
      [N, N, S, N, I, N, N, N, N, N, S, O, O, N, N, O, N],
      [N, S, N, S, N, N, N, N, O, N, N, N, N, O, N, N, N],
      [N, N, S, N, S, N, N, N, O, O, O, S, N, N, O, S, N],
      [N, N, N, N, N, N, N, N, O, N, N, N, N, N, N, S, N],
      [N, O, N, N, N, N, N, S, N, N, N, N, N, S, N, N, O]
    ];
    return typeChart[uint8(type1)][uint8(type2)];
  }

  // NOTE: to use this value, need to divide by 10
  function getEffectValue(PokemonType type1, PokemonType type2) internal pure returns(uint8) {
    TypeEffective effect = getTypeEffective(type1, type2);
    if (effect == TypeEffective.Immune) return 0;
    else if (effect == TypeEffective.NotVery) return 5;
    else if (effect == TypeEffective.Normal) return 10;
    else return 20;
  }

  function getTotalEffectValue(PokemonType moveType, PokemonType defenderType1, PokemonType defenderType2) internal pure returns(uint8) {
    uint8 value1 = getEffectValue(moveType, defenderType1);
    uint8 value2 = defenderType2 == PokemonType.None ? 1 : getEffectValue(moveType, defenderType2);
    return value1 * value2 / 10 / 10;
  }

  
}