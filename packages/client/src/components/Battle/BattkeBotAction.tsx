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

export const wait_block = 50;

export const BattleBotAction = (props: {battleID: any}) => {
  // const {battleID} = props;

  const {battleID, player_turn_pokemon, isPvE} = useBattleContext();

  const {
    api: { battle },
  } = useMUD();
  
  console.log("battleiD", battleID, player_turn_pokemon, isPvE)
  // battle(battleID, "0x00", 0)
  console.log("bot action submitted")

  return (
    <>
      {/* <BlockLeft startBlock={commit} duration={wait_block}/> */}
    </>
  )

}