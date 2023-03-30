// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibBattle } from "../libraries/LibBattle.sol";

import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";

import { BattleSystem, ID as BattleSystemID } from "./BattleSystem.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "./SpawnPokemonSystem.sol";


import { BattleType } from "../BattleType.sol";

uint256 constant ID = uint256(keccak256("system.Crawl"));

contract CrawlSystem is System {

  uint256 entropyNonce;
  
  uint8 constant team_size = 4;

  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    return executeTyped(abi.decode(args, (Coord)));
  }

  // 1) if there is no commited
  function executeTyped(Coord memory coord) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);

    PositionComponent position = PositionComponent(getAddressById(components, PositionComponentID));
    require(LibMap.distance(position.getValue(playerID), coord) == 1, "can only move to adjacent spaces");
    
    // note: it assume player has teamID; revert otherwise
    require(!LibBattle.isPlayerInBattle(components, playerID), "cannot move during a battle");

    require(LibMap.obstructions(world, coord).length == 0, "this space is obstructed");
    require(LibMap.players(world, coord).length == 0, "this space has player");

    if (LibMap.levelChecks(world, coord).length > 0) {
      uint32 levelCheck = LibMap.getLevelCheck(components, LibMap.levelChecks(world, coord)[0]);
      uint256[] memory pokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, playerID);
      for (uint i; i<pokemonIDs.length; i++) {
        require(LibPokemon.getLevel(components, pokemonIDs[i]) <= levelCheck, "pokemon level too high");
      }
    }

    position.set(playerID, coord);

    if (LibMap.encounterTriggers(world, coord).length > 0) {
      require(LibTeam.playerIDToTeamPokemonIDs(components, playerID).length != 0, "no team pokemons");
      
      // TODO: use a random number to get encounterTrigger & pokemon index from array
      // 20% chance to trigger encounter
      uint256 rand = uint256(keccak256(abi.encode(++entropyNonce, playerID, coord, block.difficulty)));
      // if (rand % 5 == 0) {
        startEncounter(playerID, coord, rand);
      // }
    }
  }

  function startEncounter(uint256 playerID, Coord memory coord, uint256 rand) internal {
    
    // 1) spawn a new encountered pokemon instance from a pokemon class and a given level
    Coord memory parcel_coord = LibMap.positionCoordToParcelCoord(coord);
    uint256 parcelID = LibMap.parcelID(world, parcel_coord)[0];
    uint32[] memory indexes = LibMap.getDungeonPokemons(components, parcelID);
    uint32 index = indexes[rand % indexes.length];
    uint32 level = LibMap.getDungeonLevel(components, parcelID);
    
    uint256 wildPokemonID = world.getUniqueEntityId();
    SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID)).executeTyped(
      index, level, wildPokemonID
    );
    
    // 2) setup newly encountered pokemonID to a new team commanded by BattleSystem
    uint256 wildTeamID = world.getUniqueEntityId();
    uint256[] memory pokemonIDs = new uint256[](team_size);
    pokemonIDs[0] = wildPokemonID;
    LibTeam.setupPokemonsToTeam(components, pokemonIDs, wildTeamID, BattleSystemID);
    
    // 3) set both encountered pokemon and player's teamID in BattleTeam
    uint256 battleID = world.getUniqueEntityId();
    uint256 playerTeamID = LibTeam.playerIDToTeamID(components, playerID);
    LibBattle.setTwoTeamsToBattle(components, playerTeamID, wildTeamID, battleID);

    // 4) init battle order
    LibBattle.initBattleOrder(components, battleID);

    // 5) init battle action timestamp
    LibBattle.setBattleActionTimestamp(components, battleID, block.timestamp);

  }



}