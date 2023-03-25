// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { HandleTeamDefeatSystem, ID as HandleTeamDefeatSystemID } from "./HandleTeamDefeatSystem.sol";
import { ID as BattleSystemID } from "./BattleSystem.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibPokemonClass } from "../libraries/LibPokemonClass.sol";
import { LibAction } from "../libraries/LibAction.sol";
import { LibArray } from "../libraries/LibArray.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol";
import { LibMove } from "../libraries/LibMove.sol";

import { BattleActionType } from "../BattleActionType.sol";
import { PokemonStats } from "../components/PokemonStatsComponent.sol";


uint256 constant ID = uint256(keccak256("system.ActionEscape"));

contract ActionEscapeSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) = abi.decode(
      args, (uint256, uint256, BattleActionType, uint256, uint256));
    return executeTyped(attackerID, targetID, action, battleID, randomness);
  }

  // note: attackerID is not a necessary input as what's next is determined
  function executeTyped(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) public returns (bytes memory) {
    
    require(msg.sender == getAddressById(world.systems(), BattleSystemID), "shall be called by BattleSystem");

    // uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);

    if (isEscaped(attackerID, targetID, randomness)) {

      _handleTeamEscaped(battleID);

      return new bytes(0);
    }

    LibBattle.resetDonePokemon(components, battleID);
  }

  function isEscaped(uint256 attackerID, uint256 targetID, uint256 randomness) internal view returns(bool) {
    // TODO: LibPokemon.getEscapeRate(components, ...)
    uint16 escape_rate = 125;
    uint16 threshold = uint16(randomness % 256);
    return escape_rate > threshold ? true : false;
  }

  function _handleTeamEscaped(uint256 battleID) private {
    // 1) remove BattlePokemons
    LibBattle.removeBattleOrder(components, battleID);

    // 2) remove all teams from TeamBattle
    LibBattle.removeAllBattleTeams(components, battleID);
  }

}
