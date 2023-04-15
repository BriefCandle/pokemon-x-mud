import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useState } from "react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";

export const TeamPokemon = (props: {setActive: any, activeComponent: any, pokemonID: string}) => { 
  const {setActive, activeComponent, pokemonID} = props;
  console.log("team pokemon", pokemonID)


  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_up = () => { return; };
  const press_down = () => { return; };
  const press_left = () => { return; };
  const press_right = () => { return; };
  const press_a = () => { return; };

  const press_b = () => { setActive(ActiveComponent.team);}
  const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.teamPokemon, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  // const press_down = () => {
  //   setSelectedItemIndex((selectedItemIndex)=> 
  //     // selectedItemIndex === menuItems.length - 1 ? selectedItemIndex : selectedItemIndex + 1
  //   )
  // }

  



  return (
    <>
      <div className="team-pokemon">
        testing
        {/* <img className="pokemon-image" src={image} alt={`${name} image`} /> */}
        {/* <div className="pokemon-name">{name}</div> */}

        {/* <div className="pokemon-stats">
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">HP:</span>
            <span className="pokemon-stat-value">{hp}</span>
          </div>
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">Attack:</span>
            <span className="pokemon-stat-value">{attack}</span>
          </div>
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">Defense:</span>
            <span className="pokemon-stat-value">{defense}</span>
          </div>
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">Special Attack:</span>
            <span className="pokemon-stat-value">{specialAttack}</span>
          </div>
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">Special Defense:</span>
            <span className="pokemon-stat-value">{specialDefense}</span>
          </div>
          <div className="pokemon-stat">
            <span className="pokemon-stat-label">Speed:</span>
            <span className="pokemon-stat-value">{speed}</span>
          </div>
        </div> */}
      </div>
      <style>
      {`
      .team-pokemon {
        display: flex;
        flex-direction: column;
        background-color: white;
        align-items: center;
        border: 2px solid #ccc;
        border-radius: 8px;
        // padding: 8px;
        width: 100%;
        height: 100%;
        box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
        position: absolute; /* Add this to allow z-index */
        z-index: 40; /* Add this to set the z-index */
      }
      
      /* Styles for the Pokemon image */
      .pokemon-image {
        width: 200px;
        height: 200px;
        object-fit: cover;
        margin-bottom: 16px;
      }
      
      /* Styles for the Pokemon name */
      .pokemon-name {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 8px;
      }
      
      /* Styles for the Pokemon stats */
      .pokemon-stats {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        margin-bottom: 16px;
      }
      `}
      </style>
    </>
  )
}