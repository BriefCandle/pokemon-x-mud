// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { EncounterComponent, ID as EncounterComponentID } from "../components/EncounterComponent.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID} from "../systems/SpawnPokemonSystem.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";

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

  function startEncounter(uint256 playerId) internal returns (uint256) {
    uint256 encounterId = world.getUniqueEntityId();
    // set up encounter: playerId -> encounterId
    EncounterComponent encounter = EncounterComponent(getAddressById(components, EncounterComponentID));
    encounter.set(playerId, encounterId);
    
    // TODO: get a random number
    // uint256 rand = uint256(keccak256(abi.encode(++entropyNonce, playerId, encounterId, block.difficulty)));
    // TODO: choose a pokemon class -- use a library function
    PokemonIndexComponent pokemonIndex = PokemonIndexComponent(getAddressById(components, PokemonIndexComponentID));
    uint32 index = 1;
    uint256 classID = pokemonIndex.getEntitiesWithValue(index)[0];
    //  TODO: choose a pokemon level -- use a library function
    uint16 level = 5;
    SpawnPokemonSystem spawnPokemon = SpawnPokemonSystem(getAddressById(world.systems(), SpawnPokemonSystemID));
    bytes memory byteID = spawnPokemon.executeTyped(classID, level);
    uint256 pokemonID = abi.decode(byteID, (uint256));
    
    // set up encounter: pokemonId -> playerId
    encounter.set(pokemonID, encounterId);
    return encounterId;
  }
}