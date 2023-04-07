import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { TeamPokemonMenu } from "./TeamPokemonMenu";
import { TeamPokemon } from "./TeamPokemon";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";

export const TeamSwitch = (props: {setActive: any, activeComponent: any, preSelectedPokemonID: string}) => { 
  const {setActive, activeComponent, preSelectedPokemonID} = props;
  const {
    components: { Team, TeamPokemons },
    api: {assembleOldTeam},
    world,
    playerEntityId,
  } = useMUD();

  const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  const teamIndex = teamIndexes.next().value;
  const pokemonIDs = getComponentValue(TeamPokemons, teamIndex)?.value as string[]; //Type.NumberArray
  useObservableValue(TeamPokemons.update$);

  const pokemonInfo: (PokemonBasicInfo | undefined) [] = pokemonIDs?.map((pokemonEntity) => {
    const pokemonIndex = world.entityToIndex.get((pokemonEntity as EntityID))
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const preSelectedIndex = pokemonIDs.indexOf(preSelectedPokemonID);
  if (preSelectedIndex === -1) return null;

  // only check when component is rendered
  useEffect(() => {
    if (preSelectedIndex === 0) setSelectedItemIndex(preSelectedIndex+1)
  }, [])

  const press_up = useCallback(() => {
    console.log(selectedItemIndex)
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[selectedItemIndex])

  const press_down = useCallback(() => {
    console.log(selectedItemIndex)
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === pokemonIDs.length - 1 ? selectedItemIndex : selectedItemIndex + 1)
  },[selectedItemIndex])

  const press_a = useCallback(() => {
    const new_pokemonIDs = handleSwap(selectedItemIndex, preSelectedIndex, pokemonIDs);
    assembleOldTeam(new_pokemonIDs);
    return setActive(ActiveComponent.team);
  }, [selectedItemIndex]);

  const handleSwap = (index1: number, index2: number, array: any[]): any[] => {
    const temp = array[index1];
    array.splice(index1, 1, array[index2]);
    array.splice(index2, 1, temp);
    return array;
  }

  const press_b = () => { setActive(ActiveComponent.menu);}

  const press_left = () => { return; };
  const press_right = () => { return; };
  const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.teamSwitch, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  return (
    <>
      <div className="team-switch">
        {pokemonInfo.map((info, index) => (
          <div 
            key={index}
            className={`menu-item ${index === selectedItemIndex || index === preSelectedIndex ? "selected" : ""}`}
          >
            <PokemonBasicInfoBar basicInfo={info}/>
          </div>
        ))}
      </div>

      <style>
      {`
        .team-switch {
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
          z-index: 40; /* Add this to set the z-index */
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