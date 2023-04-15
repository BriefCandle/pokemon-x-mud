import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { getAddress } from "ethers/lib/utils";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useEntityQuery, useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex, HasValue } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";

import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { PCOwnedMenu } from "./PCOwnedMenu";
import { PCTeam } from "./PCTeam";
import { PCTeamSelect } from "./PCTeamSelect";
import { useMapContext } from "../../mud/utils/MapContext";

export const PCOwned = () => { 
  const {setActive, activeComponent} = useMapContext();
  const {
    components: { OwnedBy, PokemonClassID },
    playerEntityId,
  } = useMUD();

  const ownedPokemonIndexes = useEntityQuery([HasValue(OwnedBy, { value: playerEntityId}), Has(PokemonClassID)])
  
  useObservableValue(OwnedBy.update$);

  const pokemonInfo: (PokemonBasicInfo | undefined) [] = ownedPokemonIndexes?.map((pokemonIndex) => {
    if (pokemonIndex !== undefined) return getTeamPokemonInfo(pokemonIndex)
    else return undefined;
  })

  console.log("ownedPokemons", ownedPokemonIndexes)

  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  // need to set it back because set to -1 when to pcTeam
  useEffect(()=> {
    if (activeComponent == ActiveComponent.pcOwned) {
      setSelectedItemIndex(0)
    }
  }, [activeComponent])

  const press_up = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_down = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === pokemonInfo.length - 1 ? selectedItemIndex : selectedItemIndex + 1)
  },[])

  const press_a = useCallback(() => {
    // const item = pokemonInfo[selectedItemIndex];
    setActive(ActiveComponent.pcOwnedMenu);
  }, [selectedItemIndex]);

  const press_b = () => { setActive(ActiveComponent.map);}

  const press_left = () => { 
    setSelectedItemIndex(-1);
    setActive(ActiveComponent.pcTeam); };

  const press_right = () => { return; };

  const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.pcOwned, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)


  return (
    <>
    <div className="pc">

    {/* PCTeamSelect as child here to directly pass selected to-team pokemon in props */}
    <div className="child">
      {activeComponent != ActiveComponent.pcTeamSelect ? 
      <PCTeam /> : null}

      {activeComponent == ActiveComponent.pcTeamSelect ?
      <PCTeamSelect pokemonIndex={ownedPokemonIndexes[selectedItemIndex]} /> : null}
      
    </div>

    <div className="child"> 
      <div className="pc-owned">
        { activeComponent == ActiveComponent.pcOwnedMenu ?
        <PCOwnedMenu /> : null}

        <h1 style={{color: "black"}}>PC</h1>
        {pokemonInfo.map((info, index) => (
          <div 
            key={index}
            className={`menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            <PokemonBasicInfoBar basicInfo={info}/>
          </div>
        ))}
      </div>
    </div>

    </div>
    <style>
      {`
        .pc {
          display: flex;
          justify-content: space-between;
          align-items: stretch;
          height: 100%;
        }
        .child {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          position: relative;
          height: 100%;
        }
        .pc-owned {
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