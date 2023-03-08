// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { BaseStatsComponent, ID as BaseStatsComponentID, PokemonStats } from "../components/BaseStatsComponent.sol";
import { StatusCondition } from "../StatusCondition.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";

uint256 constant ID = uint256(keccak256("system.SpawnPokemon"));

// spawn pokemon instance 
// normally called by other system so that said instance 
// can be owned or thrown into battle
contract SpawnPokemonSystem is System { 
  constructor(IWorld _world, address _components) System(_world, _components) {  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 classID, uint16 level) = abi.decode(args, (uint256, uint16));
    return executeTyped(classID, level);
  }

  function executeTyped(uint256 classID, uint16 level) public returns (bytes memory) {
    uint256 entityId = world.getUniqueEntityId();

    // get pokemon exp & class max hp 
    BaseStatsComponent baseStats = BaseStatsComponent(getAddressById(components, BaseStatsComponentID));
    PokemonStats memory stats = baseStats.getValue(classID);

    // TODO: calculate exp value based on dungeon type & given level

    // TODO: get move classIDs from pokemonclassIDs

    // instantiate pokemon 
    PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
    pokemonInstance.set(entityId, PokemonInstance(classID, 0, 0, 0, 0, 0, 1, uint32(stats.HP), StatusCondition.None));

    return abi.encode(entityId);
  }
}
  