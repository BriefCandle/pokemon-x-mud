// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID } from "../components/TeamPokemonsComponent.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibAction } from "../libraries/LibAction.sol";
import { LibTeam } from "../libraries/LibTeam.sol";

import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";

uint256 constant ID = uint256(keccak256("system.Battle"));

contract BattleSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) {
  }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 pokemonID, uint256 targetID, BattleActionType action) = abi.decode(
      args, (uint256, uint256, BattleActionType));
    return executeTyped(pokemonID, targetID, action);
  }

  function executeTyped(uint256 pokemonID, uint256 targetID, BattleActionType action) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);
    uint256 battleID = LibBattle.playerIDToBattleID(components, playerID);
    
    // check if player's team's first pokemon == pokemonID
    uint256[] memory teamPokemons = LibBattle.getTeamPokemons(components, playerID);
    require(teamPokemons[0] == pokemonID, "Battle: player cannot command pokemon");

    // check if enemy team's first pokemon == targetID
    uint256[] memory enemyPokemons = LibBattle.getEnemyPokemons(components, playerID);
    require(enemyPokemons[0] == targetID, "Battle: player cannot battle against pokemon");
    
    // check battle type against action
    BattleType battleType = LibBattle.getBattleType(components, battleID);
    require(LibBattle.checkActionAvailable(battleType, action), "Battle: player cannot use action");
     
    // get which pokemon can go next
    if (!LibBattle.isBattleOrderExist(components, battleID)) {
      LibBattle.setBattleOrder(components, pokemonID, targetID, battleID);
    }
    uint256 pokemonNext = LibBattle.getBattleNextOrder(components, battleID);

    // in cases player fighting NPC or Encounter &&
    // it is NOT their turn to act, BattleSystem plays as a bot
    if (pokemonNext != pokemonID && 
       (battleType == BattleType.NPC || battleType == BattleType.Encounter)) {
      botBattle(pokemonID, targetID, battleID, ID);
    } else {    
      // in other cases, it has to be player's turn to act
      require(pokemonNext == pokemonID, "Battle: not player's turn to act");
      doAction(pokemonID, targetID, action, battleID, playerID);
    }
  }


  function botBattle(uint256 pokemonID, uint256 targetID, uint256 battleID, uint256 playerID) internal {
    // TODO: decide which action to take; most likely, Move, a pseudo-random num of non-zero move
    BattleActionType action = BattleActionType.Move0;
    doAction(targetID, pokemonID, action, battleID, playerID);
  }

  function doAction(uint256 pokemonID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 playerID) internal {
    bool resolved = true;
    if (action == BattleActionType.Move0 || action == BattleActionType.Move1 || action == BattleActionType.Move2 || action == BattleActionType.Move3) {
      uint8 moveNumber = LibPokemon.moveTypeToMoveNumber(action);
      bool pokemonDead = false; 
      bool targetDead = false;
      (resolved, pokemonDead, targetDead) = LibAction.doMoveAction(
        components, pokemonID, targetID, moveNumber, playerID);
      // if (pokemonDead) handleOwnDeadPokemon(pokemonID, battleID, playerID);
      // if (targetDead) handleEnemyDeadPokemon(targetID, battleID, playerID);
    }
    else if (action == BattleActionType.UsePokeball) 
      LibAction.doUsePokeballAction();

    // only reset battle order when resolve
    if (resolved == true) LibBattle.resetDonePokemon(components, battleID);
  }

  // delete BattleOrder of battleID 
  // move up next pokemon in player's team unless all left are dead pokemons
  // then call handleDefeat
  function handleOwnDeadPokemon(uint256 pokemonID, uint256 battleID, uint256 playerID) internal {
    if (LibBattle.isBattleOrderExist(components, battleID)) LibBattle.deleteBattleOrder(components, battleID);

    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    // if (getNextAlivePokemon(teamID) == 0) {
      // handleDefeatByPokemon();
    // }
  }

  // function handleEnemyDeadPokemon(uint256 pokemonID, uint256 battleID, uint256 playerID) internal {

  // }

  // // return 0 when no pokemon left alive
  // function getNextAlivePokemon(uint256 teamID) internal view returns(uint256 pokemonID) {}

  // function handleDefeatByPokemon() internal {}

  // function handleDefeatByNPC() internal {}

  // function handleDefeatByPlayer() internal {}

  // function doSwitch() internal {}



}