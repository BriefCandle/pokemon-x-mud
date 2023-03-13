// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibBattle } from "../libraries/LibBattle.sol";

import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { EncounterComponent, ID as EncounterComponentID } from "../components/EncounterComponent.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID} from "../systems/SpawnPokemonSystem.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID, TeamPokemons } from "../components/TeamPokemonsComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";

import { BattleTeamComponent, ID as BattleTeamComponentID } from "../components/BattleTeamComponent.sol";
import { BattleSystem, ID as BattleSystemID } from "./BattleSystem.sol";


import { BattleType } from "../BattleType.sol";

uint256 constant ID = uint256(keccak256("system.Crawl"));

contract CrawlSystem is System {
  uint256 internal entropyNonce = 1;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    return executeTyped(abi.decode(args, (Coord)));
  }

  function executeTyped(Coord memory coord) public returns (bytes memory) {
    uint256 playerId = addressToEntity(msg.sender);

    PositionComponent position = PositionComponent(getAddressById(components, PositionComponentID));
    require(LibMap.distance(position.getValue(playerId), coord) == 1, "can only move to adjacent spaces");

    // TODO: when in battle, cannot move
    // EncounterComponent encounter = EncounterComponent(getAddressById(components, EncounterComponentID));
    // require(!encounter.has(entityId), "cannot move during an encounter");

    require(LibMap.obstructions(world, coord).length == 0, "this space is obstructed");
    require(LibMap.players(world, coord).length == 0, "this space has player");

    position.set(playerId, coord);

    if (canTriggerEncounter(coord)) {
      // 20% chance to trigger encounter
      // uint256 rand = uint256(keccak256(abi.encode(++entropyNonce, playerId, coord, block.difficulty)));
      // if (rand % 5 == 0) {
        startEncounter(playerId);
      // }
    }
  }

  function canTriggerEncounter(Coord memory coord) internal view returns (bool) {
    return LibMap.encounterTriggers(world, coord).length > 0;
  }

  function startEncounter(uint256 playerId) internal {
    // 1) spawn a new encountered pokemon instance from a pokemon class and a given level
    // TODO: determine pokemon classID & level from index from dungeon info & a random number -- use a library function
    uint32 index=1;
    uint8 level=5;
    uint256 wildPokemonID = spawnNewPokemon(index, level);
    
    // 2) Assign encountered pokemonID to a new team commanded by BattleSystem
    uint256 wildTeamID = world.getUniqueEntityId();
    setPokemonToTeam(wildPokemonID, wildTeamID);
    
    // 3) set both encountered pokemon and player's teamID in BattleTeam
    uint256 battleID = world.getUniqueEntityId();
    setBattleInfo(wildTeamID, playerId, battleID);

  }

  function spawnNewPokemon(uint32 index, uint8 level) internal returns (uint256 pokemonID) {
    // uint256 rand = uint256(keccak256(abi.encode(++entropyNonce, playerId, encounterId, block.difficulty)));
    uint256 classID = LibPokemon.pokemonIndexToClassID(components, index);
    SpawnPokemonSystem spawnPokemon = SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID));
    pokemonID = abi.decode(spawnPokemon.executeTyped(classID, level), (uint256));
  }

  function setPokemonToTeam(uint256 pokemonID, uint256 teamID) internal {
    uint256[6] memory pokemonIDs = [pokemonID,0,0,0,0,0];
    LibTeam.assignPokemonsToTeam(components, pokemonIDs, teamID);
    LibTeam.setTeamAsOwner(components, pokemonIDs, teamID);
    LibTeam.assignTeamCommander(components, teamID, BattleSystemID);
  }

  function setBattleInfo(uint256 teamID, uint256 playerID, uint256 battleID) internal {
    uint256 playerTeamID = LibTeam.playerIDToTeamID(components, playerID);
    LibBattle.setTwoTeamsToBattle(components, playerTeamID, teamID, battleID);
  }

}