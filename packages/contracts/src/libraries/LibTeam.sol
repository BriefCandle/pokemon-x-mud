// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID, TeamPokemons } from "../components/TeamPokemonsComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";


library LibTeam {

  function assignPokemonsToTeam(IUint256Component components, uint256[6] memory pokemonIDs, uint256 teamID) public {
    TeamPokemonsComponent teamPokemons = TeamPokemonsComponent(getAddressById(components, TeamPokemonsComponentID));
    TeamPokemons memory t = TeamPokemons(pokemonIDs[0], pokemonIDs[1], pokemonIDs[2], pokemonIDs[3], pokemonIDs[4], pokemonIDs[5]);
    teamPokemons.set(teamID, t);
  }

  function assignTeamCommander(IUint256Component components, uint256 teamID, uint256 commanderID) public {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    team.set(teamID, commanderID);
  }

  function setTeamAsOwner(IUint256Component components, uint256[6] memory pokemonIDs, uint256 teamID) public {
    OwnedByComponent ownedBy = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    for (uint i=0; i<pokemonIDs.length; i++) {
      ownedBy.set(pokemonIDs[i], teamID);
    }
  }

  function playerIDToTeamID(IUint256Component components, uint256 playerID) internal view returns(uint256 teamID) {
    TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    teamID = team.getEntitiesWithValue(playerID)[0];
  }

}