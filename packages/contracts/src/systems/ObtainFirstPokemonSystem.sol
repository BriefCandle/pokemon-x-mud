// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "../systems/SpawnPokemonSystem.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID } from "../components/PokemonInstanceComponent.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";

import { LibTeam } from "../Libraries/LibTeam.sol";

uint256 constant ID = uint256(keccak256("system.ObtainFirstPokemon"));

// user submit a pokemon classID to spawn a pokemon of level 5 to the 
// player team the player can command
contract ObtainFirstPokemonSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 classID) = abi.decode(args, (uint256));
    return executeTyped(classID);
  }

  function executeTyped(uint256 classID) public returns (bytes memory) {
    // TODO: need to write some authorization/condition check here
    // for example, a component to check for first pokemon true/false
    uint256 playerID = addressToEntity(msg.sender);

    // 1) spawn a pokemon of level 5
    SpawnPokemonSystem spawnPokemon = SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID));
    uint8 level = 5;
    bytes memory byteID = spawnPokemon.executeTyped(classID, level);
    uint256 pokemonID = abi.decode(byteID, (uint256));
    
    // 2) init a new team, commanded by player
    uint256 teamID = world.getUniqueEntityId();
    TeamComponent team = TeamComponent(getAddressById(components,TeamComponentID));
    team.set(teamID, playerID);

    // 3) assign pokemonID to new team
    LibTeam.assignPokemonsToTeam(components, [pokemonID, 0, 0, 0, 0, 0], teamID);

    // 4) pokemon is owned by team
    OwnedByComponent owneBy = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    owneBy.set(pokemonID, teamID);

  }
}