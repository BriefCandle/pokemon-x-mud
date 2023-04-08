import { useEffect, useMemo, useRef, useState } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";


export const BattlePlayerAction = (props: {setActive: any, activeComponent: any}) => {
  const {setActive, activeComponent} = props;

  const {
    components: { Position, Player, TerrainPC, TerrainNurse, TerrainSpawn },
    api: { crawlBy },
    playerEntity,
  } = useMUD();

  console.log("BattlePlayerAction")

  return (
    <div></div>
  )

}