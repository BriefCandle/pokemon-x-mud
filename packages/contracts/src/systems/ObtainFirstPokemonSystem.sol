// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";

import { SpawnPlayerSystem, ID as SpawnPlayerSystemID } from "./SpawnPlayerSystem.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "./SpawnPokemonSystem.sol";

import { LibTeam } from "../Libraries/LibTeam.sol";
import { LibPokemon } from "../Libraries/LibPokemon.sol";

uint256 constant ID = uint256(keccak256("system.ObtainFirstPokemon"));

// user submit a pokemon classID to spawn a pokemon of level 5 to the 
// player team the player can command
contract ObtainFirstPokemonSystem is System {

  uint8 constant team_size = 4;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 index, uint256 playerID) = abi.decode(args, (uint32, uint256));
    return executeTyped(index, playerID);
  }

  function executeTyped(uint32 index, uint256 playerID) public returns (bytes memory) {

    require(msg.sender == getAddressById(world.systems(), SpawnPlayerSystemID), "shall be called by SpawnPlayerSystem");

    require(index==1 || index==4 || index==7, "must be the original");
    
    // because playerID is never removed, player would NOT have pokemons in team before

    // 1) spawn two pokemons of level 5
    uint32 level = 5;
    uint256 pokemonID1 = world.getUniqueEntityId();
    SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID)).executeTyped(
      index, level, pokemonID1
    );

    uint256[] memory pokemonIDs = new uint256[](team_size);
    pokemonIDs[0] = pokemonID1;
    
    // 2) setup team
    uint256 teamID = world.getUniqueEntityId();
    LibTeam.setupPokemonsToTeam(components, pokemonIDs, teamID, playerID);

  }
}