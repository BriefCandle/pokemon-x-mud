// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID, TeamPokemons } from "../components/TeamPokemonsComponent.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibAction } from "../libraries/LibAction.sol";

import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";

uint256 constant ID = uint256(keccak256("system.Battle"));

contract BattleSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) {
  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 pokemonID, uint256 targetID, uint8 moveNumber, BattleActionType action) = abi.decode(
      args, (uint256, uint256, uint8, BattleActionType));
    return executeTyped(pokemonID, targetID, moveNumber, action);
  }

  function executeTyped(uint256 pokemonID, uint256 targetID, uint8 moveNumber, BattleActionType action) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);
    uint256 battleID = LibBattle.playerIDToBattleID(components, playerID);
    
    // check if player's team's first pokemon == pokemonID
    TeamPokemons memory teamPokemons = LibBattle.getTeamPokemons(components, playerID);
    require(teamPokemons.member0 == pokemonID, "Battle: player cannot command pokemon");

    // check if enemy team's first pokemon == targetID
    TeamPokemons memory enemyPokemons = LibBattle.getEnemyPokemons(components, playerID);
    require(enemyPokemons.member0 == targetID, "Battle: player cannot battle against pokemon");
    
    // check battle type against action
    BattleType battleType = LibBattle.getBattleType(components, battleID);
    require(LibBattle.checkActionAvailable(battleType, action), "Battle: player cannot use action");
     
    // get which pokemon can go next
    if (!LibBattle.checkBattleOrderExist(components, battleID)) {
      LibBattle.setBattleOrder(components, pokemonID, targetID, battleID);
    }
    uint256 pokemonNext = LibBattle.getBattleNextOrder(components, battleID);

    // in cases where player is fighting against NPC or Encounter &&
    // it is NOT their turn to act, BattleSystem plays as a bot
    if (pokemonNext != pokemonID && 
       (battleType == BattleType.NPC || battleType == BattleType.Encounter)) {
      doBotBattle(pokemonID, targetID);
      LibBattle.resetDonePokemon(components, battleID, targetID);
    } else {    
      // in other cases, it has to be player's turn to act
      require(pokemonNext == pokemonID, "Battle: not player's turn to act");
      doAction(pokemonID, targetID, moveNumber, action);
      LibBattle.resetDonePokemon(components, battleID, pokemonID);
    }
  }


  // TODO: check whether move has been commited and now requires revealation

  function doBotBattle(uint256 pokemonID, uint256 targetID) internal {
    // TODO: 1) decide which action to take; most likely, Move
    BattleActionType action = BattleActionType.Move;
    // TODO: 2) decide which moveNumber; most likely, a pseudo-random num of non-zero move
    uint8 moveNumber = 0;
    doAction(targetID, pokemonID, moveNumber, action);
  }

  function doAction(uint256 pokemonID, uint256 targetID, uint8 moveNumber, BattleActionType action) internal {
    if (action == BattleActionType.Move) 
      LibAction.doMoveAction(components, pokemonID, targetID, moveNumber);
    else if (action == BattleActionType.UsePokeball) 
      LibAction.doUsePokeballAction();
  }





}