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


uint256 constant ID = uint256(keccak256("system.ActionPokeball"));

contract ActionPokeballSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) = abi.decode(
      args, (uint256, uint256, BattleActionType, uint256, uint256));
    return executeTyped(attackerID, targetID, action, battleID, randomness);
  }

  // note: attackerID is not a necessary input as what's next is determined
  function executeTyped(uint256 attackerID, uint256 targetID, BattleActionType action, uint256 battleID, uint256 randomness) public returns (bytes memory) {
    
    require(msg.sender == getAddressById(world.systems(), BattleSystemID), "shall be called by BattleSystem");

    // TODO: remove item from ItemComponent
    // if pokeball NOT available, set randomness to 255;


    if (isCaught(targetID, randomness)) {
      uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);

      _handleCaughtPokemon(targetID, teamID);

      if (LibTeam.isTeamDefeat(components, teamID)) {
        HandleTeamDefeatSystem(getAddressById(world.systems(), HandleTeamDefeatSystemID)).executeTyped(
          teamID
        );
        // return new bytes(0);
      }
    }

    // LibBattle.resetDonePokemon(components, battleID);
  }

  // https://bulbapedia.bulbagarden.net/wiki/Catch_rate
  function isCaught(uint256 pokemonID, uint256 randomness) internal view returns(bool) {
    uint16 catch_rate = LibPokemon.getCatchRate(components, pokemonID);
    uint16 threshold = uint16(randomness % 256);
    return catch_rate > threshold ? true : false;
  }

  function _handleCaughtPokemon(uint256 targetID, uint256 teamID) private {
    uint256 enemyTeamID = LibBattle.teamIDToEnemyTeamID(components, teamID);

    LibTeam.removePokemonFromTeamPokemons(components, targetID, teamID);

    LibTeam.assignPokemonToTeam(components, targetID, enemyTeamID);

    uint256 battleID = LibBattle.teamIDToBattleID(components, teamID);
    LibBattle.removePokemonFromBattleOrder(components, targetID, battleID);
  }

}
