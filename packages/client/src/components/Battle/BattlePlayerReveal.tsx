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


export const wait_block = 20;

export const BattlePlayerReveal = (props: {commit: number, next_PokemonIndex: any, battleID: any}) => {
  const {commit, next_PokemonIndex, battleID} = props;

  const {
    world,
    components: {RNGActionType, RNGTarget},
    api: { battle },
  } = useMUD();
  
  const blockNumber = useBlockNumber();
  // console.log("battle player reveal blockNumber", blockNumber)

  if (blockNumber == undefined) return null;
  
  const remaining_blocks = commit + wait_block - blockNumber
  if (remaining_blocks < 0) {
    console.log(next_PokemonIndex, "next_PokemonIndex")
    const action = getComponentValue(RNGActionType, next_PokemonIndex as EntityIndex)?.value;
    const target = getComponentValue(RNGTarget, next_PokemonIndex as EntityIndex)?.value;
    console.log("action", action)
    console.log("target", target)

    if (!action || !target) return null;
    battle(battleID, target, action)
    console.log("reveal commit")
  }



  return (
    <>
      <BlockLeft startBlock={commit} duration={wait_block}/>
    </>
  )

}