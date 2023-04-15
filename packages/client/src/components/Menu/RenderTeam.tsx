import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { TeamPokemonMenu } from "./TeamPokemonMenu";
import { TeamPokemon } from "./TeamPokemon";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { TeamSwitch } from "./TeamSwitch";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { useMapContext } from "../../mud/utils/MapContext";

export const RenderTeam = () => { 
  // const {setActive, activeComponent, playerIndex} = props;
  const { activeComponent, setActive, interactCoord, setInteractCoord, thatPlayerIndex, setThatPlayerIndex} = useMapContext();

  const {
    components: { Team, TeamPokemons },
    world,
    playerEntityId,
  } = useMUD();

  const playerID = world.entities[thatPlayerIndex];
  const teamIndexes = getEntitiesWithValue(Team, {value: playerID} as ComponentValue<{value: any}>)?.values();
  const teamIndex = teamIndexes.next().value;
  
  const player_teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  const player_teamIndex = player_teamIndexes.next().value;
  const isPlayerTeam = player_teamIndex === teamIndex ? true : false;

  const pokemonIDs = useComponentValue(TeamPokemons, teamIndex)?.value as string[]; //Type.NumberArray
  // useObservableValue(TeamPokemons.update$);

  const pokemonInfo: (PokemonBasicInfo | undefined) [] = pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })
  
  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_up = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_down = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === pokemonIDs.length - 1 ? selectedItemIndex : selectedItemIndex + 1)
  },[])
  const press_a = useCallback(() => {
    const item = pokemonIDs[selectedItemIndex];
    if (item == "0x00") return null;
    return isPlayerTeam ? setActive(ActiveComponent.teamPokemonMenu) : setActive(ActiveComponent.teamPokemon);
  }, [selectedItemIndex]);

  const press_b = () => { setActive(ActiveComponent.map);}

  const press_left = () => { return; };
  const press_right = () => { return; };
  const press_start = () => { isPlayerTeam ? setActive(ActiveComponent.menu): setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.team, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)



  return (
    <>
      { activeComponent == ActiveComponent.teamPokemonMenu ? 
      <TeamPokemonMenu setActive={setActive} activeComponent={activeComponent} pokemonID={pokemonIDs[selectedItemIndex]}/> : null }
      
      { activeComponent == ActiveComponent.teamPokemon ? 
      <TeamPokemon setActive={setActive} activeComponent={activeComponent} pokemonID={pokemonIDs[selectedItemIndex]}/> : null }
      
      { activeComponent == ActiveComponent.teamSwitch ? 
      <TeamSwitch setActive={setActive} activeComponent={activeComponent} preSelectedPokemonID={pokemonIDs[selectedItemIndex]}/> : null }
      
      <div className="team">
        {pokemonInfo.map((info, index) => (
          <div 
            key={index}
            className={`menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            <PokemonBasicInfoBar basicInfo={info}/>
          </div>
        ))}
      </div>

      <style>
      {`
        .team {
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