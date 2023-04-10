import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { TimeLeft } from "./TimeLeft";
import { BigNumber } from "ethers";

export const ActionTimeDuration = 1200; 

const cx = 30;
const cy = 30;
const r = 15;

export const TimeLeftAction = (props: {battleID: EntityID}) => {
            
  const {battleID} = props;

  const {
    world,
    components: { BattleActionTimestamp },
  } = useMUD();


  const battleIndex = world.getEntityIndexStrict(battleID);
  const startTimestamp_hex = getComponentValue(BattleActionTimestamp, battleIndex)?.value
  const startTimestamp = BigNumber.from(startTimestamp_hex).toNumber()

  console.log("timestamp", Date.now() * 0.001)


  return (
    <TimeLeft startTimestamp={startTimestamp} max_duration={ActionTimeDuration}/>
  );
}