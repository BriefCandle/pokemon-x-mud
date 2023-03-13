// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";

import { BattleActionType } from "../BattleActionType.sol";

import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";


uint256 constant ID = uint256(keccak256("system.BattleBot"));

contract BattleBotSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) {
  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 pokemonID, uint256 targetID) = abi.decode(
      args, (uint256, uint256));
    return executeTyped(pokemonID, targetID);
  }

  function executeTyped(uint256 pokemonID, uint256 targetID) public returns (bytes memory) {
    require(msg.sender == getAddressById(world.systems(), BattleSystemID), 
      "BattleBot: not called by BattleSystem");
    
  }
}