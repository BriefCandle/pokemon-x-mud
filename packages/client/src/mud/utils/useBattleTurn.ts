import {  } from "@latticexyz/recs";
import { useEffect, useMemo, useState } from "react";
import { useMUD } from "../MUDContext";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { ethers , BigNumber, utils} from 'ethers';


  // Player's Turn
  // if player's turn and his nextPokemonID has an unrevealed action (use block number > ), then reveal it
  
  // PvE && not player's turn
  // if PvE && not player's turn, if no commit or there is but block number >, call system.Battle, else, wait until block number or player's turn
  
  // PvP && not player's turn
  // if PvP && not player's turn, check if BattleActionTimestamp has passed, call system.Battle if yes; else, wait until time elapses or player's turn


export function useBattleTurn(props: {setActive: any, activeComponent: any, 
  player_turn_pokemon: any, next_pokemonID: any}) {
  
    const {
    network: { blockNumber$ },
  } = useMUD();
  const [blockNumber, setBlockNumber] = useState<number>();

  useEffect(() => {
    const subscription = blockNumber$.subscribe((newBlockNumber) => setBlockNumber(newBlockNumber));
    return () => subscription.unsubscribe();
  }, [blockNumber$]);

  return blockNumber;
}


export const useGetCommit = (next_pokemonID: any) => {
  const {
    components: {RNGPrecommit},
    world
  } = useMUD();

  return useMemo(() => {
    const next_PokemonIndex = world.entityToIndex.get(next_pokemonID as EntityID)
    const commit_hex = getComponentValue(RNGPrecommit, next_PokemonIndex as EntityIndex)?.value;
    return commit_hex ? BigNumber.from(commit_hex).toNumber() : undefined;
  }, [RNGPrecommit])
}

// not player's turn if return -1
export const useGetPlayerNextIndexInTeam = (battleIndex: any) => {
  const player_pokemonIDs = useGetPlayerTeamPokemonIDs();
  const next_pokemonID = useGetNextPokemonID(battleIndex);
  return player_pokemonIDs.indexOf(next_pokemonID)
}

export const useGetNextPokemonID = (battleIndex: any) => {
  const {
    components: {BattlePokemons},
    world
  } = useMUD();

  return useMemo(()=> {
    // const battleID = useGetBattleID() as any;
    // const battleIndex = world.getEntityIndexStrict(battleID);
    const battle_pokemonIDs = getComponentValue(BattlePokemons, battleIndex)?.value as string[];
    return battle_pokemonIDs[0];
  },[BattlePokemons])
}

export const battleSystemID = utils.keccak256(utils.toUtf8Bytes('system.Battle'));

export const useIsPvE = () => {
  const {
    components: {Team},
  } = useMUD();

  const enemy_teamIndex = useGetEnemyTeamIndex();
  return useMemo(() => {
    const enemy_playerID = getComponentValue(Team, enemy_teamIndex)?.value.toString();
    return enemy_playerID == battleSystemID ? true : false;
  }, [enemy_teamIndex])
}

export const useGetEnemyTeamPokemonIDs = () => {
  const teamIndex = useGetEnemyTeamIndex();
  return useGetTeamPokemonIDs(teamIndex);
}

export const useGetEnemyTeamIndex = () => {
  const {
    components: {TeamBattle},
  } = useMUD();

  const battleID = useGetBattleID();
  return useMemo(()=> {
    const player_teamIndex = useGetPlayerTeamIndex();
    const teamBattleIndexes = getEntitiesWithValue(TeamBattle, {value: battleID})?.values();
    return findFirstNotValue(teamBattleIndexes, player_teamIndex);
  }, [battleID])
}

export const useGetBattleID = () => {
  const {
    components: {TeamBattle},
  } = useMUD();

  const teamIndex = useGetPlayerTeamIndex();
  return getComponentValue(TeamBattle, teamIndex)?.value;
}

export const useGetPlayerTeamIndex = () => {
  const {
    components: {Team},
    playerEntityId,
  } = useMUD();
  return useMemo(() => {
    const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
    return teamIndexes.next().value;
  }, [])

}

export const useGetPlayerTeamPokemonIDs = () => {
  const teamIndex = useGetPlayerTeamIndex();
  return useGetTeamPokemonIDs(teamIndex);
}

export const useGetTeamPokemonIDs = (teamIndex: EntityIndex) => {
  const {
    components: {TeamPokemons},
  } = useMUD();

  return useMemo(()=>{
    return getComponentValue(TeamPokemons, teamIndex)?.value as string[];
  },[TeamPokemons])
}


export const findFirstNotValue = (iterable: IterableIterator<any>, notValue: any): any=> {
  for (const element of iterable) {
    if (element !== notValue) {
      return element;
    }
  }
  return undefined
}