// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "../systems/SpawnPokemonSystem.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID } from "../components/PokemonInstanceComponent.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamComponent, ID as TeamComponentID, Team } from "../components/TeamComponent.sol";



uint256 constant ID = uint256(keccak256("system.ObtainFirstPokemon"));

// TODO: a temporary solution being called in SpawnSystem.sol when a player is spawned
// 1) spawn an classIndex = 1 pokemon; 2) set owner to player; 3) set it to new team; 4) set owner to team
contract ObtainFirstPokemonSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 classID, uint256 playerID) = abi.decode(args, (uint256, uint256));
    return executeTyped(classID, playerID);
  }

  function executeTyped(uint256 classID, uint256 playerID) public returns (bytes memory) {
    // need to write some authorization/condition check here

    // 1) spawn an classIndex = 1 pokemon;
    SpawnPokemonSystem spawnPokemon = SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID));
    uint16 level = 5;
    // bytes memory byteID = spawnPokemon.executeTyped(classID, level);
    // uint256 pokemonID = abi.decode(byteID, (uint256));

    // // 2) set owner to player;
    // OwnedByComponent owneBy = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    // // owneBy.set(pokemonID, playerID);

    // // 3) set pokemonID to a new team, pokemon is owned by team, team is owned by player
    // TeamComponent team = TeamComponent(getAddressById(components, TeamComponentID));
    // uint256 teamID = world.getUniqueEntityId();
    // Team memory t = Team(pokemonID, 0, 0, 0, 0, 0);
    // team.set(teamID, t);
    // owneBy.set(pokemonID, teamID);
    // owneBy.set(teamID, playerID);
  }
}