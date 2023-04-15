import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { pokemonIndexToMoveNames } from "../../mud/utils/pokemonInstance";


export const BattlePlayerTarget = () => {

  const {
    world,
    api: { battle },
    // components: { PokemonMoves, MoveName },
  } = useMUD();

  const {battleID, next_pokemonID, enemy_pokemonIDs, setActive, setSelectedAction, selectedAction, setSelectedTarget, selectedTarget, activeComponent,
  isBusy, setIsBusy, setMessage} = useBattleContext();
  
  // useEffect(()=>{
  //   setSelectedTarget(0);
  // },[])

  const moveNames = useMemo(()=> {
    return pokemonIndexToMoveNames(world.getEntityIndexStrict(next_pokemonID))
  },[next_pokemonID])
   

  // ----- key input functions -----
  const press_left = useCallback(() => {
    console.log("selectedTarget",selectedTarget)
    console.log("right", findPreviousIndex(selectedTarget, enemy_pokemonIDs))
    setSelectedTarget(findPreviousIndex(selectedTarget, enemy_pokemonIDs));
  },[selectedTarget])

  const press_right = useCallback(() => {
    console.log("selectedTarget",selectedTarget)
    const nextIndex = findNextIndex(selectedTarget, enemy_pokemonIDs)
    console.log("next", nextIndex)
    setSelectedTarget(nextIndex);
  },[selectedTarget])

  const press_a = useCallback(async () => {
    setMessage(`waiting player commits action type: ${moveNames[selectedAction]}...`);
    setIsBusy(true)
    try {
      console.log("player starts commit", battleID, enemy_pokemonIDs[selectedTarget], selectedAction)
      await battle(battleID, enemy_pokemonIDs[selectedTarget], selectedAction);
      setIsBusy(false)
      console.log("player finishes commit")
    } catch (error) {
      console.error("battle player target:", error)
    }
    setSelectedTarget(-1);   
    // setActive(ActiveComponent.battle) 
  }, [selectedTarget]);

  const press_b = () => { 
    setSelectedTarget(-1);
    // setActive(ActiveComponent.battlePlayerAction);
  }

  const press_up = () => { return; };

  const press_down = () => { return; };

  const press_start = () => { return; };

  useKeyboardMovement( true, //activeComponent == ActiveComponent.battlePlayerTarget, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  const findNextIndex = (index: number, ids: string[]): number => {
    for (let i=index+1; i<ids.length; i++) {
      console.log("id", i)
      if (ids[i]!="0x00") return i;
    }
    return index;
  }

  const findPreviousIndex = (index: number, ids: string[]): number => {
    for (let i=index-1; i >=0; i--) {
      // console.log("id", i)
      if (ids[i]!="0x00") return i;
    }
    return index;
  }

  return (
    <>
      <h1 style={{color: "black"}}>Player selecting a target</h1> 
    </>
  )

}