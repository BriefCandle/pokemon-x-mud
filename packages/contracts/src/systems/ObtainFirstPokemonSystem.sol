// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";

import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "../systems/SpawnPokemonSystem.sol";

import { LibTeam } from "../Libraries/LibTeam.sol";
import { LibPokemon } from "../Libraries/LibPokemon.sol";

uint256 constant ID = uint256(keccak256("system.ObtainFirstPokemon"));

// user submit a pokemon classID to spawn a pokemon of level 5 to the 
// player team the player can command
contract ObtainFirstPokemonSystem is System {

  uint8 constant team_size = 4;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 index) = abi.decode(args, (uint32));
    return executeTyped(index);
  }

  function executeTyped(uint32 index) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);

    // TODO: player must NOT have pokemons in team

    // 1) spawn two pokemons of level 5
    uint32 level = 5;
    uint256 pokemonID1 = world.getUniqueEntityId();
    SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID)).executeTyped(
      index, level, pokemonID1
    );
    uint256 pokemonID2 = world.getUniqueEntityId();
    SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID)).executeTyped(
      index, level, pokemonID2
    );

    uint256[] memory pokemonIDs = new uint256[](team_size);
    pokemonIDs[0] = pokemonID1;
    pokemonIDs[2] = pokemonID2;

    // 2) setup team
    uint256 teamID = world.getUniqueEntityId();
    LibTeam.setupPokemonsToTeam(components, pokemonIDs, teamID, playerID);

  }
}