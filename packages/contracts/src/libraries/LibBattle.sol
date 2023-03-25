// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Arrays} from "@openzeppelin/contracts/utils/Arrays.sol";

import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID } from "../components/TeamPokemonsComponent.sol";
import { TeamBattleComponent, ID as TeamBattleComponentID } from "../components/TeamBattleComponent.sol";
import { BattlePokemonsComponent, ID as BattlePokemonsComponentID } from "../components/BattlePokemonsComponent.sol";
import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";

import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { MoveTarget } from "../MoveTarget.sol";

import {LibPokemon} from "./LibPokemon.sol";
import {LibMove} from "./LibMove.sol";
import {LibTeam} from "./LibTeam.sol";
import {LibArray} from "./LibArray.sol";



// setter & getter for BattleTeamC, BattleOrderC
library LibBattle {

  uint8 constant battleOrder_size = 8;

  error LibBattle__BattleIDNotExist();
  error LibBattle__BattleOrderNotExist();
  error LibBattle__EnemyPokemonIDNotExist();
  
  /** -------------------- Manage Battle Order ---------------------- */
  // if checkBattleOrder is false, we setBattleOrder(), and then we getBattleOrder();
  // else, we getBattleOrder(), which returns whichever pokemon goes first

  function isBattleOrderExist(IUint256Component components, uint256 battleID) internal view returns(bool ) {
    BattlePokemonsComponent battleOrderC = BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID));
    if (!battleOrderC.has(battleID)) return false;
    else {
      uint256[] memory battleOrder = battleOrderC.getValue(battleID);
      if (battleOrder.length == 0) return false;
      else return true;
    }
  }

  // (?) revert when battleOrder not exist or length = 0
  function deleteBattleOrder(IUint256Component components, uint256 battleID) internal {
    BattlePokemonsComponent battleOrderC = BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID));
    battleOrderC.remove(battleID);
  }

  function initBattleOrder(IUint256Component components, uint256 battleID) internal{
    uint256[] memory pokemonIDs = getAllPokemonsInBattle(components, battleID);
    uint256[] memory pokemon_SPD = new uint256[](pokemonIDs.length);
    for (uint i; i<pokemonIDs.length; i++) {
      pokemon_SPD[i] = LibPokemon.getPokemonBattleStats(components, pokemonIDs[i]).SPD;
    }
    // TODO: use quickSort to sort pokemonIDs based on pokemon_SPD from high to low
    BattlePokemonsComponent battleOrderC = BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID));
    battleOrderC.set(battleID, pokemonIDs);
  }

  // revert when battleOrder not exist or length = 0
  function getBattleNextOrder(IUint256Component components, uint256 battleID) internal view returns(uint256) {
    return battleIDToBattleOrder(components, battleID)[0];
  }

  // revert when battleOrder not exist or length = 0
  function resetDonePokemon(IUint256Component components, uint256 battleID) internal {
    uint256[] memory battleOrder = battleIDToBattleOrder(components, battleID);
    uint256[] memory newBattleOrder = LibArray.removeFirstFromArray(battleOrder);
    setBattleOrder(components, battleID, newBattleOrder);
  }

  // if there a value then remove, shift elements to the left;
  // if no value, return same array, do nothing
  function removePokemonFromBattleOrder(IUint256Component components, uint256 pokemonID, uint256 battleID) internal {
    uint256[] memory battleOrder = battleIDToBattleOrder(components, battleID);
    uint256[] memory newBattleOrder = LibArray.removeValueFromArray(pokemonID, battleOrder);
    if (newBattleOrder.length != battleOrder.length) setBattleOrder(components, battleID, newBattleOrder);
  }

  


  // ------------- getter for BattleOrder: battleID->pokemonIDs  --------------
  // revert when battleOrder exists & length > 0
  function battleIDToBattleOrder(IUint256Component components, uint256 battleID) internal view returns (uint256[] memory pokemonIDs) {
    BattlePokemonsComponent battleOrder = BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID));
    if(!isBattleOrderExist(components, battleID)) revert LibBattle__BattleOrderNotExist();
    return battleOrder.getValue(battleID);
  }

  // ------------- setter for BattleOrder: battleID->pokemonIDs  --------------
  function setBattleOrder(IUint256Component components, uint256 battleID, uint256[] memory pokemonIDs) internal {
    BattlePokemonsComponent battleOrder = BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID));
    battleOrder.set(battleID, pokemonIDs);
  }

  // ---------------------------

  function setTwoTeamsToBattle(IUint256Component components, uint256 teamID1, uint256 teamID2, uint256 battleID) internal {
    TeamBattleComponent battleTeam = TeamBattleComponent(getAddressById(components, TeamBattleComponentID));
    battleTeam.set(teamID1, battleID);
    battleTeam.set(teamID2, battleID);
  }

  function removeBattleOrder(IUint256Component components, uint256 battleID) internal {
    BattlePokemonsComponent(getAddressById(components, BattlePokemonsComponentID)).remove(
      battleID);
  }

  function removeBattleTeam(IUint256Component components, uint256 teamID) internal {
    TeamBattleComponent(getAddressById(components, TeamBattleComponentID)).remove(
      teamID);
  }

  function removeAllBattleTeams(IUint256Component components, uint256 battleID) internal {
    uint256[] memory teamIDs = battleIDToTeamIDs(components, battleID);
    for (uint i=0; i<teamIDs.length; i++) {
      removeBattleTeam(components, teamIDs[i]);
    }
  }



  // ------------- getter for BattleTeam: teamID->battleID  --------------

  function teamIDToBattleID(IUint256Component components, uint256 teamID) internal view returns(uint256 battleID) {
    TeamBattleComponent battleTeam = TeamBattleComponent(getAddressById(components, TeamBattleComponentID));
    if (!battleTeam.has(teamID)) revert LibBattle__BattleIDNotExist();
    battleID = battleTeam.getValue(teamID);
  }

  function battleIDToTeamIDs(IUint256Component components, uint256 battleID) internal view returns (uint256[] memory teamIDs) {
    TeamBattleComponent battleTeam = TeamBattleComponent(getAddressById(components, TeamBattleComponentID));
    teamIDs = battleTeam.getEntitiesWithValue(battleID);
  }



  
  // ---------------------------

  // playerID -(TeamC)-> teamID -(BattleTeamC) -> battleID
  function playerIDToBattleID(IUint256Component components, uint256 playerID) internal view returns (uint256 battleID) {
    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    battleID = teamIDToBattleID(components, teamID);
  }

  // battleID -(BattleTeamC)-> teamIDs -(TeamC)-> playerIDs 
  function battleIDToCommanderIDs(IUint256Component components, uint256 battleID) internal view returns (uint256[] memory) {
    uint256[] memory teamIDs = battleIDToTeamIDs(components, battleID);
    uint256[] memory commanderIDs = new uint256[](teamIDs.length);
    for (uint i=0; i<teamIDs.length; i++) {
      commanderIDs[i] = LibTeam.teamIDToPlayerID(components, teamIDs[i]); 
    }
    return commanderIDs;
  }

  // note: only consist of non-zero pokemonIDs
  function getAllPokemonsInBattle(IUint256Component components, uint256 battleID) internal view returns(uint256[] memory pokemonIDs) {
    uint256[] memory teamIDs = battleIDToTeamIDs(components, battleID);
    uint countIDs = 0;
    for (uint i; i<teamIDs.length; i++) {
      countIDs += LibTeam.teamIDToPokemonIDs(components, teamIDs[i]).length;
    }
    uint counter = 0;
    pokemonIDs = new uint256[](countIDs);
    for (uint i; i<teamIDs.length; i++) {
      uint256[] memory p_ids = LibTeam.teamIDToPokemonIDs(components, teamIDs[i]);
      for (uint j; j<p_ids.length; j++) {
        pokemonIDs[counter] = p_ids[j]; 
        counter++;
      }
    }
  }

  // assume 2-team battle
  function playerIDToEnemyTeamID(IUint256Component components, uint256 playerID) internal view returns (uint256 enemyTeamID) {
    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    enemyTeamID = teamIDToEnemyTeamID(components, teamID);
  }

  function teamIDToEnemyTeamID(IUint256Component components, uint256 teamID) internal view returns (uint256 enemyTeamID) {
    uint256 battleID = teamIDToBattleID(components, teamID);
    uint256[] memory teamIDs = battleIDToTeamIDs(components, battleID);
    for (uint i =0; i< teamIDs.length; i++) {
      if (teamIDs[i] != teamID) enemyTeamID = teamIDs[i];
    }
  }

  // filter out zero
  function playerIDToEnemyPokemons(IUint256Component components, uint256 playerID) internal view returns (uint256[] memory enemyPokemons) {
    uint256 ememyTeamID = playerIDToEnemyTeamID(components, playerID);
    enemyPokemons = LibTeam.teamIDToPokemonIDs(components, ememyTeamID);
  }

  function requireEnemyTeamHasTargetID(IUint256Component components, uint256 playerID, uint256 targetID) internal view returns (bool) {
    uint256[] memory enemyPokemons = playerIDToEnemyPokemons(components, playerID);
    for (uint i; i<enemyPokemons.length; i++) {
      if (enemyPokemons[i] == targetID) return true;
    }
    revert LibBattle__EnemyPokemonIDNotExist();
  }

  function getBattleType(IUint256Component components, uint256 battleID) internal view returns (BattleType) {
    uint256[] memory commanderIDs = battleIDToCommanderIDs(components, battleID);
    for (uint i=0; i<commanderIDs.length; i++) {
      uint256 commanderID = commanderIDs[i];
      if (commanderID == BattleSystemID) return BattleType.Encounter;
    }
    // TODO: implement a logic to check fight against NPC
    return BattleType.OtherPlayer;
  } 


}