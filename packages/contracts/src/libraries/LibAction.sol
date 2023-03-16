// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { BattleTeamComponent, ID as BattleTeamComponentID } from "../components/BattleTeamComponent.sol";
import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance} from "../components/PokemonInstanceComponent.sol";
import { PokemonClassInfoComponent, ID as PokemonClassInfoComponentID, PokemonClassInfo } from "../components/PokemonClassInfoComponent.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { BattleType } from "../BattleType.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { MoveTarget } from "../MoveTarget.sol";


import {LibPokemon} from "./LibPokemon.sol";
import { LibBattle } from "./LibBattle.sol";
import { LibMove } from "./LibMove.sol";
import { LibRNG } from "./LibRNG.sol";

library LibAction {

  /**
   * update PokemonInstanceComponent for attack and defend pokemons
   * return their fainting status to BattleSystem to change BattleOrder 
   */
  function doMoveAction (IUint256Component components, uint256 pokemonID, uint256 targetID, uint8 moveNumber, uint256 playerID) internal 
  returns(bool resolved, bool pokemonDead, bool targetDead) {
    if (LibRNG.isExist(components,playerID)) {
      // must commit to the right move number
      require(uint8(LibRNG.getActionType(components, playerID))==moveNumber, 
        "Battle: wrong move number");
      uint256 randomNumber = LibRNG.getRandomness(components, playerID);
      uint256 moveID = LibPokemon.getPokemonMoveID(components, pokemonID, moveNumber);
      (PokemonInstance memory attackI, PokemonInstance memory defendI) = LibMove.
        calculateMoveEffectOnPokemons(components, pokemonID, targetID, moveID, randomNumber);

      PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
      pokemonInstance.set(pokemonID, attackI);
      pokemonInstance.set(targetID, defendI);
      LibRNG.removeRequest(components, playerID);
      return (true, isPokemonDead(attackI), isPokemonDead(defendI));
    } else {
      // if there is no commit, commit and return false
      LibRNG.requestRandomness(components, playerID, BattleActionType(moveNumber));
      return (false, false, false);
    }
  }

  function isPokemonDead(PokemonInstance memory pokemonInstance) private pure returns (bool) {
    return pokemonInstance.currentHP==0 ? true : false;
  }

  function doUsePokeballAction() internal {
    // TODO: a check on whether caught; 
    // if caught, transfer ownership from team to player; delete team info
  }



}