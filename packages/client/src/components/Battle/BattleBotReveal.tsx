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

export const BattleBotReveal = (props: {commit: any, next_PokemonIndex: any,battleID: any}) => {
  const {commit, next_PokemonIndex, battleID} = props;

  const {
    api: { battle },
  } = useMUD();
  
  const blockNumber = useBlockNumber();
  console.log("battle bot reveal blockNumber", blockNumber)

  if (blockNumber == undefined) return null;
  
  const remaining_blocks = commit + wait_block - blockNumber
  if (remaining_blocks < 0) {
    // battle(battleID, "0x00", 0)
    console.log("bot action submitted")
  }

  return (
    <>
      <BlockLeft startBlock={commit} duration={wait_block}/>
    </>
  )

}