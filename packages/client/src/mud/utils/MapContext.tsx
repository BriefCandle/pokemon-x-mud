import { useComponentValue } from "@latticexyz/react";
import { EntityIndex, EntityID, ComponentValue, getEntitiesWithValue, getComponentValue } from "@latticexyz/recs";
import { createContext, ReactNode, useCallback, useContext, useMemo, useState } from "react";
import { useMUD } from "../MUDContext";
import { ethers , BigNumber, utils} from 'ethers';
import { ActiveComponent, useActiveComponent } from "../../useActiveComponent";

import { useGetBattleID, useGetCommit, useGetEnemyTeamIndex, useGetPlayerTeamIndex, useGetPlayerTeamPokemonIDs } from "./useBattleTurn";
import { BattleActionType } from "../../enum/battleActionType";

export enum PlayerDirection {
  Up,
  Down,
  Left,
  Right
}

type MapContextType = {
  activeComponent: any;
  setActive: any;

  playerDirection: any;
  setPlayerDirection: any;

  interactCoord: any;
  setInteractCoord: any;

  thatPlayerIndex: any;
  setThatPlayerIndex: any;
}

const MapContext = createContext<MapContextType | undefined>(undefined);

export const MapProvider = (props: {children: ReactNode}) => {

  const currentValue = useContext(MapContext);
  if (currentValue) throw new Error("BattleProvider can only be used once")

  const {
    // components: { Team, TeamBattle, TeamPokemons, BattlePokemons, RNGPrecommit },
    world,
    playerEntity
  } = useMUD();

  const { activeComponent, setActive } = useActiveComponent();
  const [playerDirection, setPlayerDirection] = useState<PlayerDirection>(PlayerDirection.Up);
  const [interactCoord, setInteractCoord] = useState<{x: number, y: number}>()
  const [thatPlayerIndex, setThatPlayerIndex] = useState<EntityIndex | null>(playerEntity)

  const value = {
    activeComponent, setActive,
    playerDirection, setPlayerDirection,
    interactCoord, setInteractCoord,
    thatPlayerIndex, setThatPlayerIndex
  }
  return <MapContext.Provider value={value}>{props.children}</MapContext.Provider>
}

export const useMapContext = () => {
  const value = useContext(MapContext);
  if (!value) throw new Error("Must be used within a BattleProvider");
  return value;
};


export const findFirstNotValue = (iterable: IterableIterator<any>, notValue: any): any=> {
  for (const element of iterable) {
    if (element !== notValue) {
      return element;
    }
  }
  return undefined
}