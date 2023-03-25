// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { BattleStats } from "../components/PokemonBattleStatsComponent.sol";

import { PokemonEVComponent, ID as PokemonEVComponentID } from "../components/PokemonEVComponent.sol";

import { PokemonClassInfo } from "../components/ClassInfoComponent.sol";
import { StatusCondition } from "../StatusCondition.sol";
import { LevelRate } from "../LevelRate.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibPokemonClass } from "../libraries/LibPokemonClass.sol";

import { ID as ObtainFirstPokemonSystemID } from "./ObtainFirstPokemonSystem.sol";
import { ID as CrawlSystemID } from "./CrawlSystem.sol";


uint256 constant ID = uint256(keccak256("system.SpawnPokemon"));

// spawn pokemon instance, to be called by other system 
contract SpawnPokemonSystem is System { 
  constructor(IWorld _world, address _components) System(_world, _components) {  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 index, uint32 level, uint256 pokemonID) = abi.decode(args, (uint32, uint32, uint256));
    return executeTyped(index, level, pokemonID);
  }

  // TODO: figure out how msg.sender works here
  function executeTyped(uint32 index, uint32 level, uint256 pokemonID) public returns (bytes memory) {
    // require(addressToEntity(msg.sender) == ObtainFirstPokemonSystemID ||
    //   addressToEntity(msg.sender) == CrawlSystemID, "Spawn Pokemon: cannot spawn");
    LibPokemon.spawnPokemon(components, pokemonID, index, level);
    // return abi.encode(pokemonID);
  }

}
  