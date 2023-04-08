import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattlePlayerAction } from "./BattlePlayerAction";
import { ethers , BigNumber, utils} from 'ethers';
import { toEthAddress } from "@latticexyz/utils";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { PokemonFrontBattle } from "../PokemonInstance/PokemonFrontBattle";
import { PokemonBackBattle } from "../PokemonInstance/PokemonBackBattle";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";

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
    components: { Team, TeamBattle, TeamPokemons, BattlePokemons },
    world,
    systems,
    playerEntityId,
  } = useMUD();

  // get all pokemon's basic info
  
  const battleIndex = world.getEntityIndexStrict(battleID);
  // get player team index
  const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  const player_teamIndex = teamIndexes.next().value;

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

  console.log("player_pokemons_info", player_pokemons_info)
  console.log("other_pokemons_info", other_pokemons_info)

  // get battleType
  const isPvE = () => {
    const other_playerID = getComponentValue(Team, other_teamIndex)?.value.toString();
    // const other_playerID_uint256 = BigNumber.from(other_playerID).toString();
    const battleSystemID = utils.keccak256(utils.toUtf8Bytes('system.Battle'));
    return other_playerID == battleSystemID ? true : false;
  }
  const isbattlePvE = isPvE();

  // get next pokemon
  const battle_pokemonIDs = getComponentValue(BattlePokemons, battleIndex)?.value as string[];
  const next_pokemonID = battle_pokemonIDs[0];

  // determine if player is next turn
  const isPlayerTurn = player_pokemonIDs.includes(next_pokemonID);
  console.log("isPlayerTurn", isPlayerTurn)

  useEffect(() =>{
    if (isPlayerTurn) {
      setActive(ActiveComponent.battlePlayerAction)
    }
  }, [activeComponent])


  console.log("battle_pokemonIDs", battle_pokemonIDs)

  // listen to pokemons's status (hp for now) from both teams

  // listen to next pokemon to check if it is player's turn

  // if it is, 1) get action timestamp to determine remaining time for action to take;
  // 2) setActive on playerTurn to let player decide which action to take

  // if it is not, determine if pvp, then wait for player's own turn;
  // if pve, calls system.battle 

  // const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  // const teamIndex = teamIndexes.next().value;
  // const pokemonIDs = getComponentValue(TeamPokemons, teamIndex)?.value as string[]; //Type.NumberArray
  // useObservableValue(TeamPokemons.update$);



  
  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_up = useCallback(() => {
    // setSelectedItemIndex((selectedItemIndex)=> 
    //   selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_down = useCallback(() => {
    // setSelectedItemIndex((selectedItemIndex)=> 
    //   selectedItemIndex === pokemonIDs.length - 1 ? selectedItemIndex : selectedItemIndex + 1)
  },[])
  const press_a = useCallback(() => {
    return setActive(ActiveComponent.teamPokemonMenu);
  }, []);

  const press_b = () => { setActive(ActiveComponent.menu);}

  const press_left = () => { return; };
  const press_right = () => { return; };
  const press_start = () => { return; };

  useKeyboardMovement(activeComponent == ActiveComponent.battle, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)



  return (
    <>  
      {/* { activeComponent == ActiveComponent.teamPokemon ? 
      <TeamPokemon setActive={setActive} activeComponent={activeComponent} pokemonID={pokemonIDs[selectedItemIndex]}/> : null }
       */}

      {/* { activeComponent == ActiveComponent.teamSwitch ? 
      <TeamSwitch setActive={setActive} activeComponent={activeComponent} preSelectedPokemonID={pokemonIDs[selectedItemIndex]}/> : null } 
       */}
      <div className="battle">
        {/* <h1 style={{color: "black"}}>Battle</h1> */}

        <div className="other-pokemon">
          { other_pokemons_info.map((pokemon_info)=> (
            <PokemonFrontBattle basicInfo={pokemon_info}/>
          ))}
        </div>

        <div className="player-pokemon">
        { player_pokemons_info.map((pokemon_info)=> (
            <PokemonBackBattle basicInfo={pokemon_info} />
          ))}
        </div>

        { activeComponent == ActiveComponent.battlePlayerAction ? 
        <BattlePlayerAction setActive={setActive} activeComponent={activeComponent}/> : null }




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

        .other-pokemon {
          height: 100px;
          background-color: white;
          display: flex;
          justify-content: flex-end;
        }

        .player-pokemon {
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
    </>
  )
}