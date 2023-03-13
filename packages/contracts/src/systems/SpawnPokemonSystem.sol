// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { PokemonEVComponent, ID as PokemonEVComponentID } from "../components/PokemonEVComponent.sol";
import { BaseStatsComponent, ID as BaseStatsComponentID, PokemonStats } from "../components/BaseStatsComponent.sol";
import { PokemonClassInfoComponent, ID as PokemonClassInfoComponentID } from "../components/PokemonClassInfoComponent.sol";
import { StatusCondition } from "../StatusCondition.sol";
import { LevelRate } from "../LevelRate.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";

uint256 constant ID = uint256(keccak256("system.SpawnPokemon"));

// spawn pokemon instance 
// normally called by other system so that said instance 
// can be owned or thrown into battle
contract SpawnPokemonSystem is System { 
  constructor(IWorld _world, address _components) System(_world, _components) {  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 classID, uint8 level) = abi.decode(args, (uint256, uint8));
    return executeTyped(classID, level);
  }

  function executeTyped(uint256 classID, uint8 level) public returns (bytes memory) {
    uint256 pokemonID = world.getUniqueEntityId();

    // get pokemon stats for max hp
    BaseStatsComponent baseStats = BaseStatsComponent(getAddressById(components, BaseStatsComponentID));
    PokemonStats memory stats = baseStats.getValue(classID);
    
    // level to exp
    PokemonClassInfoComponent classInfoC = PokemonClassInfoComponent(getAddressById(components, PokemonClassInfoComponentID));
    LevelRate levelRate = classInfoC.getValue(classID).levelRate;
    uint32 exp = LibPokemon.levelToExp(levelRate, level);

    // TODO: get move classIDs from pokemonclassIDs
    uint256[4] memory moves = LibPokemon.getDefaultMoves(components, classID, level);

    // instantiate pokemon 
    PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
    pokemonInstance.set(pokemonID, PokemonInstance(classID, moves[0], moves[1], moves[2], moves[3], 0, exp, level, uint32(stats.HP), StatusCondition.None, 0,0,0,0,0,0,0,0,0));

    PokemonEVComponent pokemonEV = PokemonEVComponent(getAddressById(components, PokemonEVComponentID));
    pokemonEV.set(pokemonID, PokemonStats(0,0,0,0,0,0));
    return abi.encode(pokemonID);
  }
}
  