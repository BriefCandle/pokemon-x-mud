import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";
import { useBlockNumber } from "../../mud/utils/useBlockNumber";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { BigNumber } from "ethers";
import { TimeLeft } from "./TimeLeft";
import { ActionTimeDuration } from "./TimeLeftAction";
import { useTimestamp } from "../../mud/utils/useTimestamp";


export const BattleForceSkip =  () => {

  const {
    world,
    components: {BattleActionTimestamp},
    api: { battle },
  } = useMUD();
  
  const {battleID, commit, setActive, isBusy, setIsBusy} = useBattleContext();

  const battleIndex = world.getEntityIndexStrict(battleID);
  const startTimestamp_hex = useComponentValue(BattleActionTimestamp, battleIndex)?.value
  const startTimestamp = BigNumber.from(startTimestamp_hex).toNumber()

  const currentTimestamp = useTimestamp();
  const remainingSeconds = Math.floor(Math.max(0, startTimestamp + ActionTimeDuration - currentTimestamp));
  

  const press_a = useCallback(async () => {
    if(remainingSeconds == 0) {    
      setIsBusy(true);
      try {
        console.log("player starts force skip")
        await battle(battleID, "0x00", 0)
        setIsBusy(false);
        console.log("bot finishes force skip")
      } catch(error) {
        console.log("battleSkipOtherPlayer: ", error)
      }}
  },[])

  const press_b = () => { return;}
  const press_left = () => { return;}
  const press_right = () => { return; };
  const press_up = () => { return; };
  const press_down = () => { return; };
  const press_start = () => { return; };

  useKeyboardMovement(true, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)


  return (
    <>
      <TimeLeft startTimestamp={startTimestamp} max_duration={ActionTimeDuration}/>
      
      {remainingSeconds == 0 ?
        <h1>Press A to force other play to skip</h1> : 
        <h1>Wait until time run out: {remainingSeconds} seconds left</h1>}

    </>
  )

}