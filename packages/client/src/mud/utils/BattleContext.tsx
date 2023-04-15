import { useComponentValue } from "@latticexyz/react";
import { EntityIndex, EntityID, ComponentValue, getEntitiesWithValue, getComponentValue } from "@latticexyz/recs";
import { createContext, ReactNode, useCallback, useContext, useMemo, useState } from "react";
import { useMUD } from "../MUDContext";
import { ethers , BigNumber, utils} from 'ethers';
import { ActiveComponent } from "../../useActiveComponent";

import { useGetBattleID, useGetCommit, useGetEnemyTeamIndex, useGetPlayerTeamIndex, useGetPlayerTeamPokemonIDs } from "./useBattleTurn";
import { BattleActionType } from "../../enum/battleActionType";

type BattleContextType = {
  battleID: EntityID;
  isPvE: boolean;
  player_teamIndex: EntityIndex;
  enemy_teamIndex: EntityIndex;
  player_pokemonIDs: EntityID[];
  enemy_pokemonIDs: EntityID[];
  next_pokemonID?: EntityID;
  player_turn_pokemon?: number; 
  commit?: number;
  commit_action?: number;
  setActive: any;
  activeComponent: any;
  selectedAction: any;
  setSelectedAction: any;
  selectedTarget: any;
  setSelectedTarget: any
  setIsBusy: any;
  isBusy: boolean;
  message: string;
  setMessage: any;
}

const BattleContext = createContext<BattleContextType | undefined>(undefined);

export const BattleProvider = (props: {children: ReactNode, battleID: any, playerEntityId: any}) => {
  const { battleID, playerEntityId } = props;

  const currentValue = useContext(BattleContext);
  if (currentValue) throw new Error("BattleProvider can only be used once")

  const {
    components: { Team, TeamBattle, TeamPokemons, BattlePokemons, RNGPrecommit, RNGActionType },
    world,
  } = useMUD();

  const player_teamIndex = useMemo(() => {
    const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
    return teamIndexes.next().value;
  }, [])

  const battleIndex = world.getEntityIndexStrict(battleID);
  const enemy_teamIndex = useMemo(()=> {
    const teamBattleIndexes = getEntitiesWithValue(TeamBattle, {value: battleID})?.values();
    return findFirstNotValue(teamBattleIndexes, player_teamIndex);
  }, [battleID])
  const player_pokemonIDs = useComponentValue(TeamPokemons, player_teamIndex)?.value as EntityID[];
  const enemy_pokemonIDs = useComponentValue(TeamPokemons, enemy_teamIndex)?.value as EntityID[];
  const battle_pokemonIDs = useComponentValue(BattlePokemons, battleIndex)?.value as string[] | undefined;
  const next_pokemonID = useMemo(()=> {
    return battle_pokemonIDs ? battle_pokemonIDs[0] : undefined;
  },[battle_pokemonIDs]) as EntityID | undefined;
  const player_turn_pokemon = next_pokemonID ? player_pokemonIDs.indexOf(next_pokemonID) : undefined;

  const enemy_playerID = useComponentValue(Team, enemy_teamIndex)?.value.toString();
  const isPvE = useMemo(() => {
    // const other_playerID_uint256 = BigNumber.from(other_playerID).toString();
    const battleSystemID = utils.keccak256(utils.toUtf8Bytes('system.Battle'));
    return enemy_playerID == battleSystemID ? true : false;
  }, [battleID])

  const next_PokemonIndex = world.entityToIndex.get(next_pokemonID as EntityID)
  const commit_hex = useComponentValue(RNGPrecommit, next_PokemonIndex as EntityIndex)?.value;
  const commit = useMemo(() => {
    return commit_hex ? BigNumber.from(commit_hex).toNumber() : undefined;
  }, [commit_hex]);

  const commit_action_hex = useComponentValue(RNGActionType, next_PokemonIndex as EntityIndex)?.value;
  const commit_action = useMemo(() => {
    return commit_action_hex ? BigNumber.from(commit_action_hex).toNumber() : undefined;
  }, [commit_action_hex]);

  const [activeComponent, setActive] = useState()
  const [selectedAction, setSelectedAction] = useState<BattleActionType>(-1);
  const [selectedTarget, setSelectedTarget] = useState(-1);
  const [isBusy, setIsBusy] = useState(false);

  const [message, setMessage] = useState("");

  const value = {
    battleID,
    isPvE,
    player_teamIndex,
    enemy_teamIndex,
    player_pokemonIDs,
    enemy_pokemonIDs,
    next_pokemonID,
    player_turn_pokemon,
    commit,
    commit_action,
    setActive,
    activeComponent,
    selectedAction,
    setSelectedAction,
    selectedTarget,
    setSelectedTarget,
    isBusy,
    setIsBusy,
    message,
    setMessage
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