import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { memo, useCallback, useEffect, useMemo, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattlePlayerAction } from "./BattlePlayerAction";
import { BattlePlayerTarget } from "./BattlePlayerTarget";
import { ethers , BigNumber, utils} from 'ethers';
import { toEthAddress } from "@latticexyz/utils";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { PokemonFrontBattle } from "../PokemonInstance/PokemonFrontBattle";
import { PokemonBackBattle } from "../PokemonInstance/PokemonBackBattle";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { BattleActionType } from "../../enum/battleActionType";
import { BattlePlayerReveal } from "./BattlePlayerReveal";
import { BattleBotAction } from "./BattkeBotAction";
import { BattleBotReveal } from "./BattleBotReveal";
import { useGetCommit, useGetNextPokemonID, useGetPlayerTeamIndex } from "../../mud/utils/useBattleTurn";
import { BattleProvider } from "../../mud/utils/BattleContext";

export const findFirstNotValue = (iterable: IterableIterator<any>, notValue: any): any=> {
  for (const element of iterable) {
    if (element !== notValue) {
      return element;
    }
  }
  return undefined
}

export const RenderBattle = (props: {setActive: any, activeComponent: any, battleID: any}) => { 
  const {setActive, activeComponent, battleID} = props;
  
  const {
    components: { Team, TeamBattle, TeamPokemons, BattlePokemons, RNGPrecommit },
    world,
    systems,
    playerEntityId,
  } = useMUD();

  // get all pokemon's basic info
  useObservableValue(RNGPrecommit.update$)
  useObservableValue(BattlePokemons.update$)
  console.log("render battle render")

  const battleIndex = world.getEntityIndexStrict(battleID);
  // get player team index
  const player_teamIndex = useGetPlayerTeamIndex();

  // get player team pokemons
  const player_pokemonIDs = getComponentValue(TeamPokemons, player_teamIndex)?.value as string[];
  console.log("player_pokemonIDs", player_pokemonIDs)

  // get other team index
  const teamBattleIndexes = getEntitiesWithValue(TeamBattle, {value: battleID})?.values();
  const other_teamIndex = findFirstNotValue(teamBattleIndexes, player_teamIndex);

  // get other team pokemons
  const other_pokemonIDs = getComponentValue(TeamPokemons, other_teamIndex)?.value as string[];

  // get basic info for both teams' pokemons
  const player_pokemons_info: (PokemonBasicInfo | undefined) [] = player_pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  const other_pokemons_info: (PokemonBasicInfo | undefined) [] = other_pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  // console.log("player_pokemons_info", player_pokemons_info)
  // console.log("other_pokemons_info", other_pokemons_info)

  // get battleType
  const isPvE = () => {
    const other_playerID = getComponentValue(Team, other_teamIndex)?.value.toString();
    // const other_playerID_uint256 = BigNumber.from(other_playerID).toString();
    const battleSystemID = utils.keccak256(utils.toUtf8Bytes('system.Battle'));
    return other_playerID == battleSystemID ? true : false;
  }
  const isbattlePvE = isPvE();

  // get next pokemon
  // const battle_pokemonIDs = getComponentValue(BattlePokemons, battleIndex)?.value as string[];
  const next_pokemonID = useGetNextPokemonID(battleIndex)

  // determine if player is next turn
  // const isPlayerTurn = player_pokemonIDs.includes(next_pokemonID);
  const player_turn_pokemon = player_pokemonIDs.indexOf(next_pokemonID)
  console.log("player_turn_pokemon", player_turn_pokemon)

  // determine if next pokemon has committed
  const next_PokemonIndex = world.entityToIndex.get(next_pokemonID as EntityID)
  // const commit_hex = getComponentValue(RNGPrecommit, next_PokemonIndex as EntityIndex)?.value;
  // const commit = commit_hex ? BigNumber.from(commit_hex).toNumber() : undefined;
  const commit = useGetCommit(next_pokemonID)
  
  console.log("commit", commit)

  // listen to pokemons's status (hp for now) from both teams

  // listen to next pokemon to check if it is player's turn

  // if it is, 1) get action timestamp to determine remaining time for action to take;
  // 2) setActive on playerTurn to let player decide which action to take

  // if it is not, determine if pvp, then wait for player's own turn;
  // if pve, calls system.battle 
  
  const [selectedAction, setSelectedAction] = useState<BattleActionType>(0);
  const [selectedTarget, setSelectedTarget] = useState(-1);

  useEffect(() =>{
    if (player_turn_pokemon != -1) {
      if (activeComponent != ActiveComponent.battlePlayerTarget && activeComponent != ActiveComponent.battlePlayerReveal) {
        setActive(ActiveComponent.battlePlayerAction)
      } 
      // if (commit) {
      //   setActive(ActiveComponent.battlePlayerReveal)
      // }
    } 
  }, [activeComponent])

  console.log("activeComponent", activeComponent)
  return (
    <BattleProvider>  
      <div className="battle">
        {/* <h1 style={{color: "black"}}>Battle</h1> */}

        <div className="other-pokemons">
          { other_pokemons_info.map((pokemon_info, index)=> (
            <PokemonFrontBattle basicInfo={pokemon_info} selected={selectedTarget == index? true:false}/>
          ))}
        </div>

        <div className="player-pokemons">
        { player_pokemons_info.map((pokemon_info, index)=> (
            <PokemonBackBattle basicInfo={pokemon_info} selected={player_turn_pokemon == index? true: false}/>
          ))}
        </div>

        { activeComponent == ActiveComponent.battlePlayerAction || 
          activeComponent == ActiveComponent.battlePlayerTarget? 
        <BattlePlayerAction 
          setActive={setActive} activeComponent={activeComponent}
          setSelectedAction={setSelectedAction} selectedAction={selectedAction}
          pokemonID={next_pokemonID as EntityID} battleID={battleID as EntityID}
        /> : null }

        { activeComponent == ActiveComponent.battlePlayerTarget ? 
        <BattlePlayerTarget 
          setActive={setActive} activeComponent={activeComponent}
          selectedAction={selectedAction}
          setSelectedTarget={setSelectedTarget} selectedTarget={selectedTarget}
          targetIDs={other_pokemonIDs as EntityID[]} battleID={battleID as EntityID}
        /> : null }

        {player_turn_pokemon !=-1 && commit ? 
        <BattlePlayerReveal commit={commit} next_PokemonIndex={next_PokemonIndex} battleID={battleID}/> : null}

        {/* {player_turn_pokemon ==-1 && isPvE() && !commit? 
        <BattleBotAction battleID={battleID}/> : null} */}
        <BattleBotAction battleID={battleID}/>

        {player_turn_pokemon ==-1 && isPvE() && commit? 
        <BattleBotReveal commit={commit} next_PokemonIndex={next_PokemonIndex} battleID={battleID}/> : null}


      </div>

      <style>
      {`
        .battle {
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          background-color: white;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          width: 100%;
          height: 100%;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
          position: absolute; /* Add this to allow z-index */
          z-index: 20; /* Add this to set the z-index */
        }

        .other-pokemons {
          height: 100px;
          background-color: white;
          display: flex;
          justify-content: flex-end;
        }

        .player-pokemons {
          height: 100px;
          background-color: white;
          display: flex;
          justify-content: flex-start;
        }
        
        .menu-item {
          display: flex;
          justify-content: center;
          flex-grow: 1;
          flex-basis: 0;
          align-items: center;
          font-family: "Press Start 2P", sans-serif;
          font-size: 16px;
          color: black;
          padding: 8px;
          margin: 4px; /* Update this to have smaller margins */
          border-radius: 12px;
          box-shadow: 0 2px 2px rgba(0, 0, 0, 0.25);
          cursor: pointer;
          text-shadow: 0 1px 1px rgba(0, 0, 0, 0.25); /* Add text shadow for effect */
        }
        
        .selected {
          color: #ffd700;
          background-color: #585858;
        }
      `}
      </style>
    </BattleProvider>
  )
}
