import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { PCTeamMenu } from "./PCTeamMenu";

export const PCTeam = (props: {setActive: any, activeComponent: any, pc_coord:{x:number,y:number}}) => { 
  console.log("pcTeam")
  const {setActive, activeComponent, pc_coord} = props;
  const {
    components: { Team, TeamPokemons },
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

  console.log("pcteam", pokemonIDs)
  
  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(-1); // because RenderMap set to pcOwned initially

  // need to set it back because set to -1 when left to pcOwned
  useEffect(()=> {
    if (activeComponent == ActiveComponent.pcTeam) {
      setSelectedItemIndex(0)
    }
  }, [activeComponent])

  const press_up = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_down = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === pokemonIDs.length ? selectedItemIndex : selectedItemIndex + 1)
  },[])

  const press_a = useCallback(() => {
    if (selectedItemIndex == pokemonIDs.length) { //save team
      return console.log("save team"); 
    }
    const item = pokemonIDs[selectedItemIndex];
    if (item == "0x00") return null;
    return setActive(ActiveComponent.pcTeamMenu);
  }, [selectedItemIndex]);

  const press_b = () => { setActive(ActiveComponent.menu);}

  const press_left = () => { return; };

  const press_right = () => { 
    setSelectedItemIndex(-1);
    setActive(ActiveComponent.pcOwned); };

  const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.pcTeam, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)



  return (
    <>
      <div className="pc-team">
        { activeComponent == ActiveComponent.pcTeamMenu ?
        <PCTeamMenu setActive={setActive} activeComponent={activeComponent} 
        pokemonIDs={pokemonIDs} index={selectedItemIndex} pc_coord={pc_coord}/> : null}

        <h1 style={{color: "black"}}>Currnet Team</h1>
        {pokemonInfo.map((info, index) => (
          <div 
            key={index}
            className={`menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            <PokemonBasicInfoBar basicInfo={info}/>
          </div>
        ))}

        {/* <button className={`menu-item ${selectedItemIndex === pokemonIDs.length ? "selected" : ""}`}
        >Save Team</button> */}
      </div>

      <style>
      {`
        .pc-team {
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