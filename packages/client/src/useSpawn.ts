import { useEntityQuery, useComponentValue } from "@latticexyz/react";
import { getComponentEntities, getComponentValue, Has } from "@latticexyz/recs";

import { uuid } from "@latticexyz/utils";
import { useCallback, useMemo } from "react";
import { useMUD } from "./mud//MUDContext";

export const useSpawn = () => {
  const {
    components: { Position, Player },
    systems,
    playerEntity,
  } = useMUD();

  // const {x, y} = useComponentValue(Position, playerEntity);
  // const canSpawn = x==0 && y==0 ? true: false; // therefore, always make (0,0) not spawnable
  // console.log(canSpawn)
  const canSpawn = true

  const spawn = useCallback(
    async () => {
      if (!canSpawn) throw new Error("Already spawned");

      const bytes = new Uint8Array(0)
      const tx = await systems["system.SpawnPlayer"].execute(bytes)
      await tx.wait();

    },[canSpawn]
  )
  return useMemo(() => ({canSpawn, spawn}), [canSpawn, spawn])

}