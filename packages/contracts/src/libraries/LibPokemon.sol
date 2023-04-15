// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { ClassInfoComponent, ID as ClassInfoComponentID, PokemonClassInfo } from "../components/ClassInfoComponent.sol";
import { ClassIndexComponent, ID as ClassIndexComponentID } from "../components/ClassIndexComponent.sol";
import { PokemonEVComponent, ID as PokemonEVComponentID } from "../components/PokemonEVComponent.sol";

import { PokemonBattleStatsComponent, ID as PokemonBattleStatsComponentID, BattleStats } from "../components/PokemonBattleStatsComponent.sol";
import { PokemonClassIDComponent, ID as PokemonClassIDComponentID } from "../components/PokemonClassIDComponent.sol";
import { PokemonExpComponent, ID as PokemonExpComponentID } from "../components/PokemonExpComponent.sol";
import { PokemonLevelComponent, ID as PokemonLevelComponentID } from "../components/PokemonLevelComponent.sol";
import { PokemonMovesComponent, ID as PokemonMovesComponentID } from "../components/PokemonMovesComponent.sol";
import { PokemonHPComponent, ID as PokemonHPComponentID } from "../components/PokemonHPComponent.sol";
import { PokemonItemComponent, ID as PokemonItemComponentID } from "../components/PokemonItemComponent.sol";
import { PokemonStatusComponent, ID as PokemonStatusComponentID } from "../components/PokemonStatusComponent.sol";


import { MoveLevelPokemonComponent, ID as MoveLevelPokemonComponentID } from "../components/MoveLevelPokemonComponent.sol";

import { LevelRate } from "../LevelRate.sol";
import { TypeEffective } from "../TypeEffective.sol";
import { PokemonType } from "../PokemonType.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { StatusCondition } from "../StatusCondition.sol";

import { LibPokemonClass } from "./LibPokemonClass.sol";


library LibPokemon {
  
  error LibPokemon__PokemonIDNotExist();

  function isPokemonIDExist(IUint256Component components, uint256 pokemonID) internal view returns(bool) {
    return PokemonClassIDComponent(getAddressById(components, PokemonClassIDComponentID)).has(pokemonID);
  }

  // instantiate a wild pokemon based on pokemonID, class index, and level
  // TODO: make it gas efficient
  function spawnPokemon(IUint256Component components, uint256 pokemonID, uint32 index, uint32 level) internal {
    uint256 classID = LibPokemon.pokemonIndexToClassID(components, index);
    
    LevelRate levelRate = LibPokemonClass.getClassInfo(components, classID).levelRate;
    uint32 exp = LibPokemon.levelToExp(levelRate, level);

    uint256[4] memory moves = LibPokemon.getDefaultMoves(components, classID, level);
    uint256[] memory moves_d = new uint256[](4);
    for (uint i=0;i<moves.length;i++) moves_d[i] = moves[i];

    uint256 itemID = 0;

    StatusCondition status = StatusCondition.None;  

    PokemonStats memory evStats = PokemonStats(0,0,0,0,0,0); 

    PokemonStats memory baseStats = LibPokemonClass.getBaseStats(components, classID);

    uint32 HP = uint32(getMaxHP(baseStats, evStats, level));
    
    setPokemoEV(components, pokemonID, evStats);
    setBattleStats(components, pokemonID, BattleStats(0,0,0,0,0,0,0,0,0));
    setClassID(components, pokemonID, classID);
    setExp(components, pokemonID, exp);
    setLevel(components, pokemonID, level);
    setMoves(components, pokemonID, moves_d);
    setItem(components, pokemonID, itemID);
    setHP(components, pokemonID, HP);
    setStatus(components, pokemonID, status);
  }

  function getMaxHP(PokemonStats memory baseStats, PokemonStats memory evStats, uint32 level) internal pure returns (uint16) {
    return (2 * uint16(baseStats.HP) + uint16(evStats.HP)/4) * uint16(level) / 100 + uint16(level) + 10;
  }

  function getPokemonIDMaxHP(IUint256Component components, uint256 pokemonID) internal view returns(uint16) {
    uint256 classID = getClassID(components, pokemonID);
    uint16 baseStats_HP = LibPokemonClass.getBaseStats(components, classID).HP;
    uint16 evStats_HP = LibPokemon.getEV(components, pokemonID).HP;
    uint32 level = LibPokemon.getLevel(components, pokemonID);
    return (2 * baseStats_HP + evStats_HP / 4) * uint16(level) / 100 + uint16(level) + 10;
  }

  // -------- getter: pokemonID -> pokemon instance ------------
  function getEV(IUint256Component components, uint256 pokemonID) internal view returns(PokemonStats memory ev){
    return PokemonEVComponent(getAddressById(components, PokemonEVComponentID)).getValue(pokemonID);
  }

  function getClassID(IUint256Component components, uint256 pokemonID) internal view returns(uint256 classID){
    return PokemonClassIDComponent(getAddressById(components, PokemonClassIDComponentID)).getValue(pokemonID);
  }

  function getHP(IUint256Component components, uint256 pokemonID) internal view returns (uint32 HP) {
    return PokemonHPComponent(getAddressById(components, PokemonHPComponentID)).getValue(pokemonID);
  }

  function getItem(IUint256Component components, uint256 pokemonID) internal view returns(uint256 itemID) {
    return PokemonItemComponent(getAddressById(components, PokemonItemComponentID)).getValue(pokemonID);
  }

  function getBattleStats(IUint256Component components, uint256 pokemonID) internal view returns (BattleStats memory battleStats) {
    return PokemonBattleStatsComponent(getAddressById(components, PokemonBattleStatsComponentID)).getValue(pokemonID);
  }

  function getExp(IUint256Component components, uint256 pokemonID) internal view returns(uint32 exp) {
    return PokemonExpComponent(getAddressById(components, PokemonExpComponentID)).getValue(pokemonID);
  }

  function getLevel(IUint256Component components, uint256 pokemonID) internal view returns(uint32 level) {
    return PokemonLevelComponent(getAddressById(components, PokemonLevelComponentID)).getValue(pokemonID);
  }

  function getMoves(IUint256Component components, uint256 pokemonID) internal view returns(uint256[] memory moves) {
    return PokemonMovesComponent(getAddressById(components, PokemonMovesComponentID)).getValue(pokemonID);
  }

  function getStatus(IUint256Component components, uint256 pokemonID) internal view returns(StatusCondition status) {
    return PokemonStatusComponent(getAddressById(components, PokemonStatusComponentID)).getValueTyped(pokemonID);
  }

  // -------- setter: pokemonID -> pokemon instance ------------
  function setPokemoEV(IUint256Component components, uint256 pokemonID, PokemonStats memory ev) internal {
    PokemonEVComponent eVC = PokemonEVComponent(getAddressById(components, PokemonEVComponentID));
    eVC.set(pokemonID, ev);
  }

  function setClassID(IUint256Component components, uint256 pokemonID, uint256 classID) internal {
    PokemonClassIDComponent classIDC = PokemonClassIDComponent(getAddressById(components, PokemonClassIDComponentID));
    classIDC.set(pokemonID, classID);
  }

  function setHP(IUint256Component components, uint256 pokemonID, uint32 HP) internal {
    PokemonHPComponent hPC = PokemonHPComponent(getAddressById(components, PokemonHPComponentID));
    hPC.set(pokemonID, HP);
  }

  function setItem(IUint256Component components, uint256 pokemonID, uint256 itemID) internal {
    PokemonItemComponent itemC = PokemonItemComponent(getAddressById(components, PokemonItemComponentID));
    itemC.set(pokemonID, itemID);
  }

  function setBattleStats(IUint256Component components, uint256 pokemonID, BattleStats memory battleStats) internal {
    PokemonBattleStatsComponent battleStatsC = PokemonBattleStatsComponent(getAddressById(components, PokemonBattleStatsComponentID));
    battleStatsC.set(pokemonID, battleStats);
  }

  function setExp(IUint256Component components, uint256 pokemonID, uint32 exp) internal {
    PokemonExpComponent expC = PokemonExpComponent(getAddressById(components, PokemonExpComponentID));
    expC.set(pokemonID, exp);
  }

  function setLevel(IUint256Component components, uint256 pokemonID, uint32 level) internal {
    PokemonLevelComponent levelC = PokemonLevelComponent(getAddressById(components, PokemonLevelComponentID));
    levelC.set(pokemonID, level);
  }

  function setMoves(IUint256Component components, uint256 pokemonID, uint256[] memory moves) internal {
    PokemonMovesComponent movesC = PokemonMovesComponent(getAddressById(components, PokemonMovesComponentID));
    movesC.set(pokemonID, moves);
  }

  function setStatus(IUint256Component components, uint256 pokemonID, StatusCondition status) internal {
    PokemonStatusComponent statusC = PokemonStatusComponent(getAddressById(components, PokemonStatusComponentID));
    statusC.set(pokemonID, status);
  }



  // calculate PokemonStats for pokemonID based on class BaseStats, instance level, instance EV
  // NOTE: neither IV, nor nature is included in this Gen III calculation
  // NOTE: HP returned is the MAX HP, not current HP
  function getPokemonInstanceStats(IUint256Component components, uint256 pokemonID) internal view returns(PokemonStats memory) {
    // exp & classID -> baseStats
    uint256 classID = getClassID(components, pokemonID);
    uint32 level = getLevel(components, pokemonID);
    PokemonStats memory baseStats = LibPokemonClass.getBaseStats(components, classID);
    PokemonStats memory evStats = getEV(components, pokemonID);
    uint16 Max_HP = (2 * uint16(baseStats.HP) + uint16(evStats.HP)/4) * uint16(level) / 100 + uint16(level) + 10;
    uint16 ATK = (2 * uint16(baseStats.ATK) + uint16(evStats.ATK)/4) * uint16(level) / 100 + 5;
    uint16 DEF = (2 * uint16(baseStats.DEF) + uint16(evStats.DEF)/4) * uint16(level) / 100 + 5;
    uint16 SPATK = (2 * uint16(baseStats.SPATK) + uint16(evStats.SPATK)/4) * uint16(level) / 100 + 5;
    uint16 SPDEF = (2 * uint16(baseStats.SPDEF) + uint16(evStats.SPDEF)/4) * uint16(level) / 100 + 5;
    uint16 SPD = (2 * uint16(baseStats.SPD) + uint16(evStats.SPD)/4) * uint16(level) / 100 + 5;
    return PokemonStats(Max_HP, ATK, DEF, SPATK, SPDEF, SPD);
  }

  // calculate PokemonStats for pokemonID based on
  function getPokemonBattleStats(IUint256Component components, uint256 pokemonID) internal view returns(PokemonStats memory) {
    PokemonStats memory pokemonInstanceStats = getPokemonInstanceStats(components, pokemonID);
    BattleStats memory battleStats = getBattleStats(components, pokemonID);
    // add multiplier from pokemon instance
    return PokemonStats(uint16(getHP(components, pokemonID)), 
      getStatsMultipled(battleStats.ATK, pokemonInstanceStats.ATK), 
      getStatsMultipled(battleStats.DEF, pokemonInstanceStats.DEF), 
      getStatsMultipled(battleStats.SPATK, pokemonInstanceStats.SPATK), 
      getStatsMultipled(battleStats.SPDEF, pokemonInstanceStats.SPDEF), 
      getStatsMultipled(battleStats.SPD, pokemonInstanceStats.SPD));
  }

  // calculate each individual stat boost based on BattleStats
  function getStatsMultipled(int8 stage, uint16 stat) internal pure returns (uint16) {
    if (stage >= 0 ) return stat * (uint16(uint8(stage)) + 2) / 2;
    else return stat * 2 / (uint16(uint8(-stage)) + 2);
  }

  function pokemonIndexToClassID(IUint256Component components, uint32 index) internal view returns (uint256 classID) {
    ClassIndexComponent pokemonIndex = ClassIndexComponent(getAddressById(components, ClassIndexComponentID));
    classID = pokemonIndex.getEntitiesWithValue(index)[0];
  }

  function getPokemonClassInfo(IUint256Component components, uint256 pokemonID) internal view returns(PokemonClassInfo memory) {
    uint256 classID = getClassID(components, pokemonID);
    return LibPokemonClass.getClassInfo(components, classID);
  }

  function getPokemonMoveID(IUint256Component components, uint256 pokemonID, uint8 moveNumber) internal view returns (uint256 moveID) {
    return getMoves(components, pokemonID)[moveNumber];
  }

  function moveTypeToMoveNumber(BattleActionType moveType) internal pure returns (uint8 moveNumber) {
    if (moveType == BattleActionType.Move0) return 0;
    else if (moveType == BattleActionType.Move1) return 1;
    else if (moveType == BattleActionType.Move2) return 2;
    else if (moveType == BattleActionType.Move3) return 3;
    else revert("not move type");
  }

  // TODO: implement a method to get the last four nonzero moves from movelLevel array according to level
  function getDefaultMoves(IUint256Component components, uint256 pokemonClassID, uint32 level) internal view returns (uint256[4] memory moves) {
    MoveLevelPokemonComponent moveLevelC = MoveLevelPokemonComponent(getAddressById(components, MoveLevelPokemonComponentID));
    uint256[] memory moveLevel = moveLevelC.getValue(pokemonClassID);
    // TODO: a temporary solution for now....
    moves[0] = moveLevel[0];
    moves[1] = moveLevel[1];
    moves[2] = moveLevel[2];
  }




  // calculate new level and exp after pokemon receives exp from defeating pokemon
  function getNewLevelAndExp(IUint256Component components, uint256 pokemonID, uint32 expAdd) internal view returns (uint32 levelNew, uint32 expNew) {
    // get pokemon instance value
    uint256 classID = getClassID(components, pokemonID);
    uint32 exp = getExp(components, pokemonID);
    uint32 level = getLevel(components, pokemonID);
    // get pokemon class info
    LevelRate levelRate = LibPokemonClass.getClassInfo(components, classID).levelRate;
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

  // calculate exp required to reach certain level
  // NOTE: the reason why there is no expToLevel is due to 
  // difficulty to perform square root
  function levelToExp(LevelRate levelRate, uint32 level) internal pure returns (uint32 exp) {
    // based on levelRate, convert exp to leve
    if (levelRate == LevelRate.Fast) 
      exp = 4* uint32(level)**3 /5;
    else if (levelRate == LevelRate.MediumFast) 
      exp = uint32(level)**3;
    else if (levelRate == LevelRate.MediumSlow) 
      exp = uint32(level)**3 / 5 * 6  + 100*uint32(level)- 140- 15 * uint32(level)**2;
    else exp = 5 * uint32(level)**3 / 4;
  }

  // calculate exp awarded for defeating target pokemon
  // https://bulbapedia.bulbagarden.net/wiki/Experience
  function getExpAward(IUint256Component components, uint256 targetID) internal view returns(uint32 exp) {
    uint256 classID = getClassID(components, targetID);
    uint32 baseExp = LibPokemonClass.getBaseExp(components, classID);

    uint32 level = getLevel(components, targetID);

    exp = level * baseExp / 5;
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

  function isPokemonDead(IUint256Component components,uint256 targetID) internal view returns(bool) {
    return getHP(components, targetID) == 0 ? true : false;
  }

    // https://bulbapedia.bulbagarden.net/wiki/Catch_rate
  function getCatchRate(IUint256Component components, uint256 pokemonID) internal view returns(uint16 alpha) {
    // TODO: pokeball type as input to calculate rate_modified
    uint16 rate_modified = 1;
    // TODO: determine pokemon status condition to calculate bonus_stats
    uint16 bonus_rate = 1;
    uint16 max_HP = getPokemonInstanceStats(components, pokemonID).HP;
    uint16 current_HP = getPokemonBattleStats(components, pokemonID).HP;
    uint16 catchRate = getPokemonClassInfo(components, pokemonID).catchRate;
    alpha = (3*max_HP - 2*current_HP) * rate_modified * catchRate / 3 / max_HP;
    alpha = alpha > 1 ? alpha : 1;
    alpha += bonus_rate;
    alpha = alpha > 255 ? 255 : alpha;

  } 


  
}