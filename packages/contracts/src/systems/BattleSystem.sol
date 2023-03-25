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

  // note: pokemonID is not a necessary input as what's next is determined
  function executeTyped(uint256 pokemonID, uint256 targetID, BattleActionType action) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);
    uint256 battleID = LibBattle.playerIDToBattleID(components, playerID);
    uint256 pokemonNext = LibBattle.getBattleNextOrder(components, battleID);

    // either 1) player can command the next pokemon, 
    // or 2) it is a case of pve && BattleSystem can command the next pokemon
    if (LibTeam.isPlayerTeamHasPokemonID(components, playerID, pokemonNext)) {
      require(pokemonID == pokemonNext, "Battle: not yet its turn");

      LibBattle.requireEnemyTeamHasTargetID(components, playerID, targetID); 

      LibAction.requireActionAvailable(components, battleID, action);

      _executeAction(pokemonNext, targetID, action, battleID);

    } else {
      BattleType battleType = LibBattle.getBattleType(components, battleID); 
      require(battleType == BattleType.NPC || battleType == BattleType.Encounter, "Battle: not pve");
      LibTeam.requirePlayerTeamHasPokemonID(components, ID, pokemonNext);

      uint256 bot_attackerID = pokemonNext;

      // TODO: LibBot method to determine following parameters 
      uint256 bot_targetID = LibBattle.playerIDToEnemyPokemons(components, ID)[0];
      BattleActionType bot_action = action;

      _executeAction(bot_attackerID, bot_targetID, bot_action, battleID);
    }
    
    // note: battle order is initalized before a battle (ex., crawl's encounter)
    // or after an action is revealed so that each round's start can get a new nextOrder
    if (!LibBattle.isBattleOrderExist(components, battleID)) {
      LibBattle.initBattleOrder(components, battleID);
    }
  }

  // 1) if there is no commit for this attackerID, then allow action of skip, or commit other actions
  // 2) if there is a commit, then need to reveal
  function _executeAction(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID) private {
    if (!LibRNG.isExist(components, attackerID)) {
      
      if (action == BattleActionType.Skip) {
        
        LibBattle.resetDonePokemon(components, battleID);
        return;
      } else {
        
        LibRNG.commit(components, attackerID, action, targetID); 
        return;
      }
    } else {

      if (LibAction.isActionMove(action)) {

        uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);

        ActionMoveSystem(getAddressById(world.systems(), ActionMoveSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
        return;
      } else if (action == BattleActionType.UsePokeball) {

        uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);
        
        ActionPokeballSystem(getAddressById(world.systems(), ActionPokeballSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
        return;
      } else if (action == BattleActionType.Escape) {
    
        uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);

        ActionEscapeSystem(getAddressById(world.systems(), ActionEscapeSystemID)).executeTyped(
          attackerID, targetID, action, battleID, randomness
        );
        return;
      } else revert("BattleSystem: no action");

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

  // function moveAction(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID) internal {

  //   uint8 moveNumber = LibAction.actionToMoveNumber(action);
  //   uint256 moveID = LibPokemon.getMoves(components, attackerID)[moveNumber];

  //   uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);

  //   LibMove.executeMove(components, attackerID, targetID, moveID, randomness);

  //   if (LibPokemon.isPokemonDead(components, targetID)){
  //     uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);
  //     _handleDeadPokemon(targetID, teamID);

  //     if (LibTeam.isTeamDefeat(components, teamID)) {
  //       _handleTeamDefeat(teamID);
  //       return;
  //     }
  //   }
  //   LibBattle.resetDonePokemon(components, battleID);

  // }


  /** -------------------- Move Action ---------------------- */

  // function _doMoveAction(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID) private {
  //   if (!LibRNG.isExist(components, attackerID)) {

  //     LibRNG.commit(components, attackerID, action, targetID); 
  //   } else {

  //     uint8 moveNumber = LibAction.actionToMoveNumber(action);
  //     uint256 moveID = LibPokemon.getMoves(components, attackerID)[moveNumber];

  //     uint256 randomness = LibRNG.reveal(components, attackerID, targetID, action);

  //     LibMove.executeMove(components, attackerID, targetID, moveID, randomness);

  //     if (LibPokemon.isPokemonDead(components, targetID)){
  //       uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);
  //       _handleDeadPokemon(targetID, teamID);

  //       if (LibTeam.isTeamDefeat(components, teamID)) {
  //         _handleTeamDefeat(teamID);
  //         return;
  //       }
  //     }
  //     LibBattle.resetDonePokemon(components, battleID);
  //   }
  // }

  /** -------------------- UsePokeball Action ---------------------- */

  // function _doUsePokeballAction() private {

  //   // commit
  //   // reveal: check pokemon catchrate and determine catch result

  //   // --- _handlePokemonCaught
  //   // --- LibBattle.resetDonePokemon(components, battleID);

  // }
  

  // /** -------------------- Handle dead pokemon from battle ---------------------- */

  // function _handleDeadPokemon(uint256 pokemonID, uint256 teamID) private {
  //   LibTeam.removePokemonFromTeamPokemons(components, pokemonID, teamID);

  //   OwnedByComponent(getAddressById(components, OwnedByComponentID)).set(
  //     pokemonID, addressToEntity(address(0))
  //   );

  //   uint256 battleID = LibBattle.teamIDToBattleID(components, teamID);
  //   LibBattle.removePokemonFromBattleOrder(components, pokemonID, battleID);
  // }

  //   /** -------------------- Handle defeated team from battle ---------------------- */

  // function _handleTeamDefeat(uint256 teamID) internal {
  //   uint256 battleID = LibBattle.teamIDToBattleID(components, teamID);

  //   // 1) remove BattleOrder
  //   LibBattle.removeBattleOrder(components, battleID);

  //   // 2) remove all teams from BattleTeam
  //   LibBattle.removeAllBattleTeams(components, battleID);

  //   // 3) remove defeat team
  //   LibTeam.removeTeam(components, teamID);

  // }





}