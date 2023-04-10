import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";


export const BattlePlayerTarget = (
  props: {setActive: any, activeComponent: any,
          selectedAction: BattleActionType,
          setSelectedTarget: React.Dispatch<React.SetStateAction<number>>, selectedTarget: number
          targetIDs: EntityID[], battleID: EntityID
  }) => {
  const {setActive, activeComponent, selectedAction, setSelectedTarget, selectedTarget, targetIDs, battleID} = props;

  const {
    world,
    api: { battle },
    // components: { PokemonMoves, MoveName },
  } = useMUD();
  
  console.log("BattlePlayerTarget")

  useEffect(()=>{
    setSelectedTarget(0);
  },[])
   

  // ----- key input functions -----
  const press_left = useCallback(() => {
    setSelectedTarget(findPreviousIndex(selectedTarget, targetIDs));
  },[selectedTarget])

  const press_right = useCallback(() => {
    setSelectedTarget(findNextIndex(selectedTarget, targetIDs));
  },[selectedTarget])

  const press_a = useCallback(() => {
    console.log("selectedTarget", targetIDs[selectedTarget]);
    console.log("selectedAction", selectedAction)
    battle(battleID, targetIDs[selectedTarget], selectedAction)
  }, [selectedTarget]);

  const press_b = () => { 
    setSelectedTarget(-1);
    setActive(ActiveComponent.battlePlayerAction);
  }

  const press_up = () => { return; };

  const press_down = () => { return; };

  const press_start = () => { return; };

  useKeyboardMovement(activeComponent == ActiveComponent.battlePlayerTarget, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  const findNextIndex = (index: number, ids: string[]): number => {
    for (let i=index; i<ids.length; i++) {
      if (ids[i]!="0x00") return i;
    }
    return index;
  }

  const findPreviousIndex = (index: number, ids: string[]): number => {
    for (let i=index; i >=0; i--) {
      if (ids[i]!="0x00") return i;
    }
    return index;
  }

  return (
    <>
    </>
  )

}