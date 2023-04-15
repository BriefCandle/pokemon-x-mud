import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";
import { useBlockNumber } from "../../mud/utils/useBlockNumber";
import { BlockLeft } from "./BlockLeft";
import { useGetBattleID, useGetCommit } from "../../mud/utils/useBattleTurn";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { getMoves, pokemonIndexToMoveNames } from "../../mud/utils/pokemonInstance";

export const wait_block = 50;

export const BattleBotAction =  () => {

  const {battleID, player_turn_pokemon, isPvE, setActive, next_pokemonID ,commit, enemy_pokemonIDs, player_pokemonIDs, isBusy, setIsBusy, setMessage} = useBattleContext();
  const {
    world,
    api: { battle },
  } = useMUD();
    
  console.log("player_turn_pokemon", player_turn_pokemon)
  console.log("next_pokemonID", next_pokemonID)
  console.log("commit", commit)
  console.log("enemy_pokemonIDs",enemy_pokemonIDs)

  // const moveNames = pokemonIndexToMoveNames(world.getEntityIndexStrict(next_pokemonID))
  // console.log("bot move names", moveNames)

  useEffect(() => {
    const botCommit = async (battleID: any) => {
      setMessage(`waiting bot commits action...`);
      setIsBusy(true);
      try {
        console.log("bot starts commit")
        await battle(battleID, "0x00", 0)
        setIsBusy(false);
        console.log("bot finishes commit")
      } catch(error) {
        console.log("battle bot reveal: ", error)
      }
    }

    if (!isBusy && battleID) {
      botCommit(battleID);
    }
  },[isBusy])

  return (
    <>
      <h1 style={{color: "black"}}>Bot completing commit</h1>
      {/* <BlockLeft startBlock={commit} duration={wait_block}/> */}
    </>
  )

}