// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { HandleTeamDefeatSystem, ID as HandleTeamDefeatSystemID } from "./HandleTeamDefeatSystem.sol";
import { HandlePokemonDeadSystem, ID as HandlePokemonDeadSystemID } from "./HandlePokemonDeadSystem.sol";
import { ID as BattleSystemID } from "./BattleSystem.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibAction } from "../libraries/LibAction.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol";
import { LibMove } from "../libraries/LibMove.sol";

import { BattleActionType } from "../BattleActionType.sol";

uint256 constant ID = uint256(keccak256("system.ActionMove"));

contract ActionMoveSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) = abi.decode(
      args, (uint256, uint256, BattleActionType, uint256, uint256));
    return executeTyped(attackerID, targetID, action, battleID, randomness);
  }

  // note: pokemonID is not a necessary input as what's next is determined
  function executeTyped(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) public returns (bytes memory) {
    require(msg.sender == getAddressById(world.systems(), BattleSystemID), "shall be called by BattleSystem");
    
    uint8 moveNumber = LibAction.actionToMoveNumber(action);
    uint256 moveID = LibPokemon.getMoves(components, attackerID)[moveNumber];

    LibMove.executeMove(components, attackerID, targetID, moveID, randomness);

    if (LibPokemon.isPokemonDead(components, targetID)){
      uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);
      HandlePokemonDeadSystem(getAddressById(world.systems(), HandlePokemonDeadSystemID)).executeTyped(
        attackerID,
        targetID
      );

      if (LibTeam.isTeamDefeat(components, teamID)) {
        HandleTeamDefeatSystem(getAddressById(world.systems(), HandleTeamDefeatSystemID)).executeTyped(
          teamID
        );
        // return new bytes(0);
      }
    }
    // LibBattle.resetDonePokemon(components, battleID);

  } 

}