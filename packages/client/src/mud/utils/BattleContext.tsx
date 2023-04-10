import { useComponentValue } from "@latticexyz/react";
import { EntityIndex, EntityID, ComponentValue, getEntitiesWithValue, getComponentValue } from "@latticexyz/recs";
import { createContext, ReactNode, useCallback, useContext, useMemo, useState } from "react";
import { useMUD } from "../MUDContext";
import { ethers , BigNumber, utils} from 'ethers';

import { useGetBattleID, useGetCommit, useGetEnemyTeamIndex, useGetPlayerTeamIndex, useGetPlayerTeamPokemonIDs } from "./useBattleTurn";

type BattleContextType = {
  battleID?: EntityID;
  isPvE: boolean;
  player_teamIndex: EntityIndex;
  enemy_teamIndex: EntityIndex;
  player_pokemonIDs: EntityID[];
  enemy_pokemonIDs: EntityID[];
  next_pokemonID: EntityID;
  player_turn_pokemon: number; 
  commit?: number;
}

const BattleContext = createContext<BattleContextType | undefined>(undefined);

export const BattleProvider = (props: {children: ReactNode}) => {
  const currentValue = useContext(BattleContext);
  if (currentValue) throw new Error("BattleProvider can only be used once")

  const {
    components: { Team, TeamBattle, TeamPokemons, BattlePokemons, RNGPrecommit },
    world,
    systems,
    playerEntityId,
  } = useMUD();

  const player_teamIndex = useMemo(() => {
    const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
    return teamIndexes.next().value;
  }, [])

  const battleID = getComponentValue(TeamBattle, player_teamIndex)?.value as any;
  const battleIndex = world.getEntityIndexStrict(battleID);
  const enemy_teamIndex = useMemo(()=> {
    const teamBattleIndexes = getEntitiesWithValue(TeamBattle, {value: battleID})?.values();
    return findFirstNotValue(teamBattleIndexes, player_teamIndex);
  }, [battleID])
  const player_pokemonIDs = useMemo(()=>{
    return getComponentValue(TeamPokemons, player_teamIndex)?.value as string[];
  },[TeamPokemons]) as EntityID[];
  const enemy_pokemonIDs = useMemo(()=>{
    return getComponentValue(TeamPokemons, enemy_teamIndex)?.value as string[];
  },[TeamPokemons]) as EntityID[];
  const next_pokemonID = useMemo(()=> {
    const battle_pokemonIDs = getComponentValue(BattlePokemons, battleIndex)?.value as string[];
    return battle_pokemonIDs[0];
  },[BattlePokemons]) as EntityID;
  const player_turn_pokemon = player_pokemonIDs.indexOf(next_pokemonID)
  const isPvE = useMemo(() => {
    const enemy_playerID = getComponentValue(Team, enemy_teamIndex)?.value.toString();
    // const other_playerID_uint256 = BigNumber.from(other_playerID).toString();
    const battleSystemID = utils.keccak256(utils.toUtf8Bytes('system.Battle'));
    return enemy_playerID == battleSystemID ? true : false;
  }, [battleID])
  const commit = useGetCommit(next_pokemonID);

  const value = {
    battleID,
    isPvE,
    player_teamIndex,
    enemy_teamIndex,
    player_pokemonIDs,
    enemy_pokemonIDs,
    next_pokemonID,
    player_turn_pokemon,
    commit
  }
  return <BattleContext.Provider value={value}>{props.children}</BattleContext.Provider>
}

export const useBattleContext = () => {
  const value = useContext(BattleContext);
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