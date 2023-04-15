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


export const wait_block = 5;

export const BattleBotReveal =  () => {

  const {
    world,
    components: {RNGActionType, RNGTarget},
    api: { battle },
  } = useMUD();
  
  const {next_pokemonID, battleID, commit, setActive, isBusy, setIsBusy, setMessage} = useBattleContext();

  const blockNumber = useBlockNumber();
  
  const remaining_blocks = commit + wait_block - blockNumber

  const moveNames = useMemo(()=> {
    return pokemonIndexToMoveNames(world.getEntityIndexStrict(next_pokemonID))
  },[])
  

  useEffect(() => {
    const botReveal = async (battleID: any, action:any) => {
      setMessage(`waiting bot to finish reveals of action type: ${moveNames[action]}...`);
      setIsBusy(true);
      try {
        console.log("bot starts reveal")
        await battle(battleID, "0x00", 0)
        setIsBusy(false);
        console.log("bot finishes reveal")
      } catch(error) {
        console.log("battle bot reveal: ", error)
      }
    }
    
    if (remaining_blocks < 0 && !isBusy && battleID && blockNumber && commit) {
      const next_PokemonIndex = world.getEntityIndexStrict(next_pokemonID);
      const action = getComponentValue(RNGActionType, next_PokemonIndex as EntityIndex)?.value;
      const target = getComponentValue(RNGTarget, next_PokemonIndex as EntityIndex)?.value;
      console.log("bot commited action", action)
      console.log("bot commited target", target)
      botReveal(battleID, action);
    }
  },[isBusy, remaining_blocks])


  return (
    <>
      <h1 style={{color: "black"}}>{remaining_blocks} blocks remain to reveal..</h1> 
      <BlockLeft startBlock={commit} duration={wait_block}/>
    </>
  )

}