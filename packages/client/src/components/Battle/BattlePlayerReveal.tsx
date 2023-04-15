import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";
import { useBlockNumber } from "../../mud/utils/useBlockNumber";
import { BlockLeft } from "./BlockLeft";
import { useGetBattleID } from "../../mud/utils/useBattleTurn";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { pokemonIndexToMoveNames } from "../../mud/utils/pokemonInstance";


export const wait_block = 10;

// display waiting circle & waiting message
export const BattlePlayerReveal = () => {

  const {
    world,
    components: {RNGActionType, RNGTarget},
    api: { battle },
  } = useMUD();

  const {battleID, player_turn_pokemon, next_pokemonID, commit, setMessage, setActive, setSelectedAction, selectedAction, setSelectedTarget, selectedTarget, activeComponent,
  isBusy, setIsBusy} = useBattleContext();

  const blockNumber = useBlockNumber();

  const moveNames = useMemo(()=> {
    return pokemonIndexToMoveNames(world.getEntityIndexStrict(next_pokemonID))
  },[])

  console.log("BattlePlayerReveal STARTs")

  // if (!blockNumber || !commit || player_turn_pokemon == -1) return null;
   
  const remaining_blocks = commit + wait_block - blockNumber

  useEffect(() => {
    const botReveal = async (battleID: any, target: any, action: any) => {
      setMessage(`waiting player to finish reveal of action type: ${moveNames[action]}...`);
      setIsBusy(true);
      try {
        console.log("player starts reveal")
        await battle(battleID, target, action)
        setIsBusy(false);
        // setActive(ActiveComponent.battle)
        console.log("player finishes reveal")
      } catch(error) {
        console.log("battle player reveal: ", error)
      }
    }
    
    if (remaining_blocks < 0 && !isBusy && player_turn_pokemon !=-1) {
      const next_PokemonIndex = world.getEntityIndexStrict(next_pokemonID);
      const action = getComponentValue(RNGActionType, next_PokemonIndex as EntityIndex)?.value;
      const target = getComponentValue(RNGTarget, next_PokemonIndex as EntityIndex)?.value;
      console.log("commited action", action)
      console.log("commited target", target)
      botReveal(battleID, target, action);
    } 
  },[isBusy, remaining_blocks])


  return (
    <>
      <h1 style={{color: "black"}}>{remaining_blocks} blocks remain to reveal..</h1> 
      
      <BlockLeft startBlock={commit} duration={wait_block}/>
    </>
  )

}