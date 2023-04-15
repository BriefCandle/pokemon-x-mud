import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { TimeLeft } from "./TimeLeft";
import { BigNumber } from "ethers";
import { useBattleContext } from "../../mud/utils/BattleContext";

export const ActionTimeDuration = 120; 

// time left for player to take action
export const TimeLeftAction = () => {
            
  const { battleID } = useBattleContext();

  const {
    world,
    components: { BattleActionTimestamp },
  } = useMUD();


  const battleIndex = world.getEntityIndexStrict(battleID);
  const startTimestamp_hex = useComponentValue(BattleActionTimestamp, battleIndex)?.value
  const startTimestamp = BigNumber.from(startTimestamp_hex).toNumber()


  return (
    <>
      <TimeLeft startTimestamp={startTimestamp} max_duration={ActionTimeDuration}/>
    </>
  );
}