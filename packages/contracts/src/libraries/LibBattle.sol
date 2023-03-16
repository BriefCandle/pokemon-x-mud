// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID } from "../components/TeamPokemonsComponent.sol";
import { BattleTeamComponent, ID as BattleTeamComponentID } from "../components/BattleTeamComponent.sol";
import { BattleOrderComponent, ID as BattleOrderComponentID, BattleOrder } from "../components/BattleOrderComponent.sol";
import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance} from "../components/PokemonInstanceComponent.sol";
import { PokemonClassInfoComponent, ID as PokemonClassInfoComponentID, PokemonClassInfo } from "../components/PokemonClassInfoComponent.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { MoveTarget } from "../MoveTarget.sol";

import {LibPokemon} from "./LibPokemon.sol";
import {LibMove} from "./LibMove.sol";




library LibBattle {
  
  // ---------- Battle Order ------------
  // if checkBattleOrder is false, we setBattleOrder(), and then we getBattleOrder();
  // else, we getBattleOrder(), which returns whichever pokemon goes first
  function isBattleOrderExist(IUint256Component components, uint256 battleID) internal view returns(bool ) {
    BattleOrderComponent battleOrderC = BattleOrderComponent(getAddressById(components, BattleOrderComponentID));
    if (!battleOrderC.has(battleID)) return false;
    else {
      uint256[] memory battleOrder = battleOrderC.getValue(battleID);
      if (battleOrder.length == 0) return false;
      else return true;
    }
  }

  // called when battleOrder exists & length > 0
  function deleteBattleOrder(IUint256Component components, uint256 battleID) internal {
    BattleOrderComponent battleOrderC = BattleOrderComponent(getAddressById(components, BattleOrderComponentID));
    battleOrderC.remove(battleID);
  }

  function setBattleOrder(IUint256Component components, uint256 pokemonID0, uint256 pokemonID1, uint256 battleID) internal{
    uint8 SPD_pokemon0 = LibPokemon.getPokemonBattleStats(components, pokemonID0).SPD;
    uint8 SPD_pokemon1 = LibPokemon.getPokemonBattleStats(components, pokemonID1).SPD;
    uint256[] memory battleOrder = new uint256[](2);
    if (SPD_pokemon0 > SPD_pokemon1) {battleOrder[0] = pokemonID1; battleOrder[1] = pokemonID0;}
    else if (SPD_pokemon0 < SPD_pokemon1) {battleOrder[0] = pokemonID0; battleOrder[1] = pokemonID1;}
    else {
      uint256 rand = uint256(keccak256(abi.encode(pokemonID0, pokemonID1, block.difficulty)));
      if ((rand & 1) == 1) {battleOrder[0] = pokemonID1; battleOrder[1] = pokemonID0;}
      else {battleOrder[0] = pokemonID0; battleOrder[1] = pokemonID1;}
    }
    BattleOrderComponent battleOrderC = BattleOrderComponent(getAddressById(components, BattleOrderComponentID));
    battleOrderC.set(battleID, battleOrder);
  }

  // called when battleOrder exists & length > 0
  function getBattleNextOrder(IUint256Component components, uint256 battleID) internal view returns(uint256) {
    BattleOrderComponent battleOrderC = BattleOrderComponent(getAddressById(components, BattleOrderComponentID));
    uint256[] memory battleOrder = battleOrderC.getValue(battleID);
    return battleOrder[battleOrder.length-1];
    // if (battleOrder.pokemon0 == 0 ) return battleOrder.pokemon1;
    // else return battleOrder.pokemon0;
  }

  // called when battleOrder exists & length > 0
  function resetDonePokemon(IUint256Component components, uint256 battleID) internal {
    BattleOrderComponent battleOrderC = BattleOrderComponent(getAddressById(components, BattleOrderComponentID));
    uint256[] memory battleOrder = battleOrderC.getValue(battleID);
    uint256[] memory newBattleOrder = new uint256[](battleOrder.length-1);
    for (uint i = 0; i < battleOrder.length - 1; i++) {
      newBattleOrder[i] = battleOrder[i];
    }
    // if (battleOrder.pokemon0 == pokemonID) battleOrder.pokemon0 = 0;
    // else battleOrder.pokemon1 = 0;
    battleOrderC.set(battleID, newBattleOrder);
  }

  // ---------------------------

  function setTwoTeamsToBattle(IUint256Component components, uint256 teamID1, uint256 teamID2, uint256 battleID) internal {
    BattleTeamComponent battleTeam = BattleTeamComponent(getAddressById(components, BattleTeamComponentID));
    battleTeam.set(teamID1, battleID);
    battleTeam.set(teamID2, battleID);
  }

  // NOTE: has to input playerID, not system address(?)
  // playerID -(TeamC)-> teamID -(BattleTeamC) -> battleID
  function playerIDToBattleID(IUint256Component components, uint256 playerID) internal view returns (uint256 battleID) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    uint256 teamID = team.getEntitiesWithValue(playerID)[0];
    BattleTeamComponent battleTeam = BattleTeamComponent(getAddressById(components, BattleTeamComponentID));
    battleID = battleTeam.getValue(teamID);
  }

  // battleID -(BattleTeamC)-> teamIDs -(TeamC)-> playerIDs 
  function battleIDToCommanderIDs(IUint256Component components,uint256 battleID) internal view returns (uint256[] memory) {
    BattleTeamComponent battleTeam = BattleTeamComponent(getAddressById(components, BattleTeamComponentID));
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    uint256[] memory teamIDs = battleTeam.getEntitiesWithValue(battleID);
    uint256[] memory commanderIDs = new uint256[](teamIDs.length);
    for (uint i=0; i<teamIDs.length; i++) {
      commanderIDs[i] = team.getValue(teamIDs[i]);
    }
    return commanderIDs;
  }

  // // battleID -(BattleTeamC)-> teamIDs -(TeamPokemons)-> member0 s
  // function battleIDToBattlingPokemons(IUint256Component components, uint256 battleID) internal view returns (uint256[] memory) {
  //   BattleTeamComponent battleTeam = BattleTeamComponent(getAddressById(components, BattleTeamComponentID));
  //   TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
  //   uint256[] memory teamIDs = battleTeam.getEntitiesWithValue(battleID);
  // }

  // playerID -(TeamC)-> teamID -(TeamPokemonsC) -> TeamPokemons
  function getTeamPokemons(IUint256Component components, uint256 playerID) internal view returns (uint256[] memory teamPokemons) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    uint256 teamID = team.getEntitiesWithValue(playerID)[0];
    TeamPokemonsComponent teamPokemonsC = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    teamPokemons = teamPokemonsC.getValue(teamID);
  }

  //  playerID -...-> battleID -...-> playerIDs[another]
  function getEnemyPlayerID(IUint256Component components, uint256 playerID) internal view returns (uint256 enemyPlayerID) {
    uint256 battleID = playerIDToBattleID(components, playerID);
    uint256[] memory commanderIDs = battleIDToCommanderIDs(components, battleID);
    for (uint i =0; i< commanderIDs.length; i++) {
      if (commanderIDs[i] != playerID) enemyPlayerID = commanderIDs[i];
    }
  }

  //  playerID -...-> battleID -...-> playerIDs[another] -> TeamPokemons
  function getEnemyPokemons(IUint256Component components, uint256 playerID) internal view returns (uint256[] memory teamPokemons) {
    uint256 ememyPlayerID = getEnemyPlayerID(components, playerID);
    return getTeamPokemons(components, ememyPlayerID);
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

  // false only if UsePokeball or Flee is used in battle against OtherPlayer and NPC
  function checkActionAvailable(BattleType battleType, BattleActionType action) internal pure returns (bool) {
    if ((battleType == BattleType.OtherPlayer || battleType == BattleType.NPC) &&
        (action == BattleActionType.UsePokeball || action == BattleActionType.Flee) ) {
      return false;
    } else return true;
  }


}