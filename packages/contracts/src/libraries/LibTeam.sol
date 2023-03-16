// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID } from "../components/TeamPokemonsComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";

import { LibPokemon } from "../libraries/LibPokemon.sol";


library LibTeam {

  function assignPokemonsToTeam(IUint256Component components, uint256[6] memory pokemonIDs, uint256 teamID) internal {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    uint256[] memory team = new uint256[](6);
    for (uint i=0; i<pokemonIDs.length; i++) {
      team[i] = pokemonIDs[i];
    }
    teamPokemons.set(teamID, team);
  }

  function assignTeamCommander(IUint256Component components, uint256 teamID, uint256 commanderID) internal {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    team.set(teamID, commanderID);
  }

  function setTeamAsOwner(IUint256Component components, uint256[6] memory pokemonIDs, uint256 teamID) internal {
    OwnedByComponent ownedBy = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    for (uint i=0; i<pokemonIDs.length; i++) {
      ownedBy.set(pokemonIDs[i], teamID);
    }
  }

  function playerIDToTeamID(IUint256Component components, uint256 playerID) internal view returns(uint256 teamID) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    teamID = team.getEntitiesWithValue(playerID)[0];
  }

  // return 0 if all in team are dead; else, return index
  function getNextAlivePokemonFromTeam(IUint256Component components, uint256 teamID) internal view returns(uint index) {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    uint256[] memory team = teamPokemons.getValue(teamID);
    for (uint i=0; i<team.length; i++) {
      PokemonInstance memory pokemon = LibPokemon.getPokemonInstance(components, team[i]);
      if (pokemon.currentHP > 0) return i;
    }
    return 0;
  }

  // 2 swaps 1 position
  function swapPokemonsWithinTeam(IUint256Component components, uint index1, uint index2) internal {

  }



}