import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { memo, useCallback, useEffect, useMemo, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattlePlayerAction } from "./BattlePlayerAction";
import { BattlePlayerTarget } from "./BattlePlayerTarget";
import { ethers , BigNumber, utils} from 'ethers';
import { toEthAddress } from "@latticexyz/utils";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { PokemonFrontBattle } from "../PokemonInstance/PokemonFrontBattle";
import { PokemonBackBattle } from "../PokemonInstance/PokemonBackBattle";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { BattleActionType } from "../../enum/battleActionType";
import { BattlePlayerReveal } from "./BattlePlayerReveal";
import { BattleBotAction } from "./BattleBotAction";
import { BattleBotReveal } from "./BattleBotReveal";
import { useGetCommit, useGetNextPokemonID, useGetPlayerTeamIndex } from "../../mud/utils/useBattleTurn";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { TimeLeftAction } from "./TimeLeftAction";
import { BattleForceSkip } from "./BattleForceSkip";


export const findFirstNotValue = (iterable: IterableIterator<any>, notValue: any): any=> {
  for (const element of iterable) {
    if (element !== notValue) {
      return element;
    }
  }
  return undefined
}

export const RenderBattle = () => { 
  
  const {
    world,
  } = useMUD();

  const {
    battleID,
    isPvE,
    player_teamIndex,
    enemy_teamIndex,
    player_pokemonIDs,
    enemy_pokemonIDs,
    next_pokemonID,
    player_turn_pokemon,
    commit,
    commit_action,
    selectedTarget,
    isBusy,
    message
  } = useBattleContext();


  // get all pokemon's basic info

  // const battleIndex = world.getEntityIndexStrict(battleID);

  // get basic info for both teams' pokemons
  const player_pokemons_info: (PokemonBasicInfo | undefined) [] = player_pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  const enemy_pokemons_info: (PokemonBasicInfo | undefined) [] = enemy_pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  // console.log("next_pokemonID",next_pokemonID)
  // console.log("enemy_pokemonIDs", enemy_pokemonIDs)
  // console.log("commit", commit)
  // console.log("player_turn_pokemon", player_turn_pokemon)
  // console.log("isPvE", isPvE)
  // console.log("commit_action", commit_action)

  // if (next_pokemonID == undefined) {
  //   return <><h1 style={{color: "black"}}>Battle ends</h1></>
  // }

  return (
    <>  
      <div className="battle">
        {/* <h1 style={{color: "black"}}>Battle</h1> */}

        <div className="other-pokemons">
          { enemy_pokemons_info.map((pokemon_info, index)=> (
            <PokemonFrontBattle basicInfo={pokemon_info} selected={selectedTarget == index? true:false}/>
          ))}
        </div>

        <div className="player-pokemons">
        { player_pokemons_info.map((pokemon_info, index)=> (
            <PokemonBackBattle basicInfo={pokemon_info} selected={player_turn_pokemon == index? true: false}/>
          ))}
        </div>
        
        <div className="battle-console"> 
          { isBusy ? 
          <h1>{message}</h1> : null}
          { player_turn_pokemon != -1 && !commit && selectedTarget == -1 && !isBusy?
          <BattlePlayerAction /> : null}
          
          { player_turn_pokemon != -1 && !commit && selectedTarget != -1 && !isBusy ? 
          <BattlePlayerTarget /> : null }

          {/* { player_turn_pokemon != -1 && commit && isBusy ? 
          <h1 style={{color: "black"}}>Player waiting for COMMIT tx to complete</h1> : null} */}


          { player_turn_pokemon != -1 && commit && !isBusy ? 
          <BattlePlayerReveal /> : null}

          {/* { player_turn_pokemon != -1 && !commit && isBusy ? 
          <h1 style={{color: "black"}}>Player waiting for REVEAL tx to complete</h1> : null} */}


          { player_turn_pokemon == -1 && isPvE && !commit && !isBusy? 
          <BattleBotAction /> : null}

          {/* { player_turn_pokemon == -1 && isPvE && commit && isBusy? 
          <h1 style={{color: "black"}}>Bot waiting for COMMIT tx to complete</h1> : null} */}
          
       
          { player_turn_pokemon == -1 && isPvE && commit && !isBusy? 
          <BattleBotReveal /> : null}   

          {/* { player_turn_pokemon == -1 && isPvE && !commit && isBusy? 
          <h1 style={{color: "black"}}>Bot waiting for REVEAL tx to complete</h1> : null} */}

          { player_turn_pokemon == -1 && !isPvE ?
           <BattleForceSkip/> : null }

          
        </div>

        {/* only display for player's turn; as to other player's turn, put in BattleForceSkip */}
        { player_turn_pokemon != -1 && !commit && !isBusy ? 
        <TimeLeftAction /> : null}


      </div>

      <style>
      {`
        .battle {
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          background-color: white;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          width: 100%;
          height: 100%;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
          position: absolute; /* Add this to allow z-index */
          z-index: 20; /* Add this to set the z-index */
        }

        .other-pokemons {
          height: 100px;
          background-color: white;
          display: flex;
          justify-content: flex-end;
        }

        .player-pokemons {
          height: 100px;
          background-color: white;
          display: flex;
          justify-content: flex-start;
        }

        .battle-console {
          height: 100px;
          background-color: white;
          display: flex;
          color: black;
          justify-content: space-between;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
        }
        
        .menu-item {
          display: flex;
          justify-content: center;
          flex-grow: 1;
          flex-basis: 0;
          align-items: center;
          font-family: "Press Start 2P", sans-serif;
          font-size: 16px;
          color: black;
          padding: 8px;
          margin: 4px; /* Update this to have smaller margins */
          border-radius: 12px;
          box-shadow: 0 2px 2px rgba(0, 0, 0, 0.25);
          cursor: pointer;
          text-shadow: 0 1px 1px rgba(0, 0, 0, 0.25); /* Add text shadow for effect */
        }
        
        .selected {
          color: #ffd700;
          background-color: #585858;
        }
      `}
      </style>
    </>
  )
}
