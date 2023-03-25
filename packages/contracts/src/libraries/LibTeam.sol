// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID } from "../components/TeamPokemonsComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";

import { LibPokemon } from "./LibPokemon.sol";
import { LibBattle } from "./LibBattle.sol";
import { LibArray } from "./LibArray.sol";


// mainly deal with TeamC, TeamPokemonsC
library LibTeam {

  uint8 constant team_size = 4;

  error LibTeam__WrongTeamSize();
  error LibTeam__PokemonIDNotExist();
  error LibTeam__PokemonNotInTeam();
  error LibTeam__TeamIDNotExist();
  error LibTeam__PlayerIDNotExist();

  /** --------------------  Process of Setting up Pokemons: to Team, OwnedBy, TeamPokemons ---------------------- */
  // set 1) pokemon ownership to teamID (OwnedBy); 
  // set 2) team commanded by commanderID (Team); 
  // set 3) pokemons order to teamID (TeamPokemons)
  function setupPokemonsToTeam(IUint256Component components, uint256[] memory pokemonIDs, uint256 teamID, uint256 playerID) internal {
    setTeamPokemons(components, pokemonIDs, teamID);
    setTeamAsOwner(components, pokemonIDs, teamID);
    setTeamCommander(components, teamID, playerID);
  }

  function setTeamPokemons(IUint256Component components, uint256[] memory pokemonIDs, uint256 teamID) internal {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    teamPokemons.set(teamID, pokemonIDs);
  }

  function setTeamCommander(IUint256Component components, uint256 teamID, uint256 commanderID) internal {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    team.set(teamID, commanderID);
  }

  function setTeamAsOwner(IUint256Component components, uint256[] memory pokemonIDs, uint256 teamID) internal {
    OwnedByComponent ownedBy = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    pokemonIDs = LibArray.filterZeroOffArray(pokemonIDs);
    for (uint i=0; i<pokemonIDs.length; i++) {
      if (!LibPokemon.isPokemonIDExist(components, pokemonIDs[i])) 
        revert LibTeam__PokemonIDNotExist();
      ownedBy.set(pokemonIDs[i], teamID);
    }
  }

  function assignPokemonToTeam(IUint256Component components, uint256 pokemonID, uint256 teamID) internal returns(bool) {
    uint256[] memory pokemonIDs = teamIDToPokemons(components, teamID);
    uint index = LibArray.getValueIndexInArray(0, pokemonIDs);
    if (index > pokemonIDs.length) return false;
    else {
      pokemonIDs[index] = pokemonID;
      setTeamPokemons(components, pokemonIDs, teamID);
      return true;
    }
  }

  function pokemonIDToTeamID(IUint256Component components, uint256 pokemonID) internal view returns (uint256){
    return OwnedByComponent(getAddressById(components, OwnedByComponentID)).getValue(pokemonID);
  }

  function pokemonIDToPlayerID(IUint256Component components, uint256 pokemonID) internal view returns (uint256) {
    uint256 teamID = pokemonIDToTeamID(components, pokemonID);
    return teamIDToPlayerID(components, teamID);
  }

  function removePokemonFromTeamPokemons(IUint256Component components, uint256 pokemonID, uint256 teamID) internal {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    uint256[] memory pokemonIDs = teamPokemons.getValue(teamID);
    uint index = pokemonIDs.length + 1;
    for (uint i=0; i<pokemonIDs.length; i++) {
      if (pokemonIDs[i] == pokemonID) index =i;
    }
    if (index == pokemonIDs.length+1) revert LibTeam__PokemonNotInTeam();
    pokemonIDs[index] = 0;
    teamPokemons.set(teamID, pokemonIDs);
  }

  function removeTeam(IUint256Component components, uint256 teamID) internal {
    TeamComponent(getAddressById(components, TeamComponentID)).remove(teamID);
  }


  /** -------------------- getter for Team: teamID->playerID ---------------------- */
  function teamIDToPlayerID(IUint256Component components, uint256 teamID) internal view returns(uint256 playerID) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    if (!team.has(teamID)) revert LibTeam__PlayerIDNotExist();
    playerID = team.getValue(teamID);
  }

  function playerIDToTeamID(IUint256Component components, uint256 playerID) internal view returns(uint256 teamID) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    uint256[] memory teamIDs = team.getEntitiesWithValue(playerID);
    if (teamIDs.length ==0) revert LibTeam__TeamIDNotExist();
    teamID = teamIDs[0];
  }

  /** -------------------- getter for TeamPokemons: teamID->pokemonIDs -------------------- */
  // note: with zero
  function teamIDToPokemons(IUint256Component components, uint256 teamID) internal view returns(uint256[] memory pokemonIDs) {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    if(!teamPokemons.has(teamID)) revert LibTeam__TeamIDNotExist();
    pokemonIDs = teamPokemons.getValue(teamID);
  }
  // note: without zero
  function teamIDToPokemonIDs(IUint256Component components, uint256 teamID) internal view returns(uint256[] memory pokemonIDs) {
    uint256[] memory pokemons_with_zero = teamIDToPokemons(components, teamID);
    pokemonIDs = LibArray.filterZeroOffArray(pokemons_with_zero);
  }

  // with zero
  function playerIDToTeamPokemons(IUint256Component components, uint256 playerID) internal view returns(uint256[] memory pokemonIDs){
    uint256 teamID = playerIDToTeamID(components, playerID);
    pokemonIDs = teamIDToPokemons(components, teamID);
  }

  // without zero
  function playerIDToTeamPokemonIDs(IUint256Component components, uint256 playerID) internal view returns(uint256[] memory pokemonIDs){
    uint256 teamID = playerIDToTeamID(components, playerID);
    pokemonIDs = teamIDToPokemonIDs(components, teamID);
  }

  function requirePlayerTeamHasPokemonID(IUint256Component components, uint256 playerID, uint256 pokemonID) internal view returns (bool){
    uint256[] memory pokemonIDs = playerIDToTeamPokemons(components, playerID);
    if (LibArray.isValueInArray(pokemonID, pokemonIDs)) return true;
    revert LibTeam__PokemonIDNotExist();
  }

  function isPlayerTeamHasPokemonID(IUint256Component components, uint256 playerID, uint256 pokemonID) internal view returns (bool){
    uint256[] memory pokemonIDs = playerIDToTeamPokemons(components, playerID);
    for (uint i; i<pokemonIDs.length; i++) {
      if (pokemonIDs[i] == pokemonID) return true;
    }
    return false;
  }


  // -------------------------------------------------------------------------------------------

  // return 0 if all in team are dead; else, return index
  function getNextAlivePokemonFromTeam(IUint256Component components, uint256 teamID) internal view returns(uint index) {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    uint256[] memory team = teamPokemons.getValue(teamID);
    for (uint i=0; i<team.length; i++) {
      if (LibPokemon.getHP(components, team[i]) > 0) return i;
    }
    return 0;
  }

  // note: need to check if index > array.length
  function getNextEmptySlotFromTeam(IUint256Component components, uint256 teamID) internal view returns(uint index) {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    uint256[] memory team = teamPokemons.getValue(teamID);
    index = LibArray.getValueIndexInArray(0, team);
  }

  function isTeamDefeat(IUint256Component components, uint256 teamID) internal view returns(bool) {
    return teamIDToPokemonIDs(components, teamID).length == 0? true : false;
  }


  // 2 swaps 1 position
  function swapPokemonsWithinTeam(IUint256Component components, uint index1, uint index2) internal {

  }



}