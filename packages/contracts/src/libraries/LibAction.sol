// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID, TeamPokemons } from "../components/TeamPokemonsComponent.sol";
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
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibMove } from "../libraries/LibMove.sol";

library LibAction {

  // TODO: implement randomness: commit and reveal 
  function doMoveAction (IUint256Component components, uint256 pokemonID, uint256 targetID, uint8 moveNumber) public {
    (PokemonInstance memory attackI, PokemonInstance memory defendI) = LibMove.
      calculateMoveEffectOnPokemons(components, pokemonID, targetID, moveNumber);
    
    PokemonInstanceComponent pokemonInstance = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
    pokemonInstance.set(pokemonID, attackI);
    pokemonInstance.set(targetID, defendI);
  }

  function doUsePokeballAction() public {
    // TODO: a check on whether caught; 
    // if caught, transfer ownership from team to player; delete team info
  }



}