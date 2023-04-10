import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";


// 1) player waits his committed action to be revealed
// 2) player waits his own calling bot's commit and reveal 
// 3) player waits his opponent to finish its actions; if not revealed, player reveal it for him

export const BattlePlayerWait = (props: {}) => {
  const {} = props;

  const {
    world,
    api: { battle },
    components: { RNGPrecommit, MoveName },
  } = useMUD();
  
  console.log("BattlePlayerWait")
   


  return (
    <>
    </>
  )

}