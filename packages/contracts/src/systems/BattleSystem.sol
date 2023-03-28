// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { ActionMoveSystem, ID as ActionMoveSystemID } from "./ActionMoveSystem.sol";
import { ActionPokeballSystem, ID as ActionPokeballSystemID } from "./ActionPokeballSystem.sol";
import { ActionEscapeSystem, ID as ActionEscapeSystemID } from "./ActionEscapeSystem.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibAction } from "../libraries/LibAction.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol";
import { LibMove } from "../libraries/LibMove.sol";

import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";

uint256 constant ID = uint256(keccak256("system.Battle"));

contract BattleSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 pokemonID, uint256 targetID, BattleActionType action) = abi.decode(
      args, (uint256, uint256, BattleActionType));
    return executeTyped(pokemonID, targetID, action);
  }

  // 1) if pokemonNext's player is NOT battleSystemID, anyone can check last time action is executed, 
  // if time has not elapsed, require commander, etc
  // 2) else when next is battleSystmeID, anyone can call; if there is a commit, cannot reveal it before pass wait block
  // note: pokemonID is not a necessary input as what's next is pre-determined
  function executeTyped(uint256 battleID, uint256 targetID, BattleActionType action) public returns (bytes memory) {
    
    uint256 pokemonNext = LibBattle.getBattleNextOrder(components, battleID);

    uint256 next_playerID = LibTeam.pokemonIDToPlayerID(components, pokemonNext);
    if (next_playerID != ID) {
      if (LibBattle.isTimeElapsed(components, battleID)) {

        // note: skip will skip no matter LibRNG is committed 
        _executeAction(pokemonNext, targetID, BattleActionType.Skip, battleID);
        
      } else {
        uint256 playerID = addressToEntity(msg.sender);
        require(playerID == next_playerID, "Battle: not your battle");
        LibTeam.requirePlayerTeamHasPokemonID(components, playerID, pokemonNext); 
        LibBattle.requireEnemyTeamHasTargetID(components, playerID, targetID); 
        LibAction.requireActionAvailable(components, battleID, action);

        _executeAction(pokemonNext, targetID, action, battleID);
      }
    } else {

      // TODO: LibBot method to determine following parameters 
      uint256 bot_targetID = LibBattle.playerIDToEnemyPokemons(components, ID)[0];
      BattleActionType bot_action = BattleActionType.Move0;

      if (LibRNG.isExist(components, pokemonNext)) {
        uint256 precommit = LibRNG.getPrecommit(components, pokemonNext);
        require(LibRNG.isPassWaitBlock(precommit), "Battle: bot has not passed wait block");
      }

      _executeAction(pokemonNext, bot_targetID, bot_action, battleID);
    }
  }

  // 1) if there is no commit for this attackerID, then allow action to skip, or player can commit other actions
  // 2) if there is a commit, then need to reveal
  // 3) if no commit, needs to handleBattleOrder when battleID still exist
  function _executeAction(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID) private {
    if (!LibRNG.isExist(components, attackerID)) {
      
      if (action == BattleActionType.Skip) {
        
        // LibBattle.resetDonePokemon(components, battleID);
      } else {
        
        LibRNG.commit(components, attackerID, action, targetID); 
        return;
      }
    } else {

      uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);

      if (LibAction.isActionMove(action)) {

        ActionMoveSystem(getAddressById(world.systems(), ActionMoveSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
      } else if (action == BattleActionType.UsePokeball) {
        
        ActionPokeballSystem(getAddressById(world.systems(), ActionPokeballSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
      } else if (action == BattleActionType.Escape) {
    
        ActionEscapeSystem(getAddressById(world.systems(), ActionEscapeSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
      } else if (action == BattleActionType.Skip) {
      }
      else revert("BattleSystem: no action");
    }

    if (LibBattle.isBattleIDExist(components, battleID)) {
      _handleBattleOrder(battleID);
    }
  }

  // note: battle order is initalized before a battle (ex., crawl's encounter)
  // or after an action is revealed so that each round's start can get a new nextOrder
  function _handleBattleOrder(uint256 battleID) internal {
    // reset next pokemon, which must exist because it is performed after action revealed;
    LibBattle.resetDonePokemon(components, battleID);

    // reset timestamp
    LibBattle.setBattleActionTimestamp(components, battleID, block.timestamp);
    
    // if battlepokemons is empty, init it
    if (!LibBattle.isBattleOrderExist(components, battleID)) {
      LibBattle.initBattleOrder(components, battleID);
    }
  }



  // function _executeRNGAction(
  //   uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID,
  //   function(uint256, uint256, BattleActionType, uint256) internal callback
  // ) internal returns (bytes memory) {
  //   if (!LibRNG.isExist(components, attackerID)) {

  //     LibRNG.commit(components, attackerID, action, targetID); 
  //   } else {

  //     callback(attackerID, targetID, action, battleID);
  //   }
  // }






}