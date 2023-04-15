import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { useMapContext } from "../../mud/utils/MapContext";

export const initPokemonList = [
  {name: "Bulbasaur", index: 1},
  {name: "Charmander", index: 4}
]


export const SpawnPlayer = () => { 

  const {
    api: {spawnPlayer}
  } = useMUD();

  
  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_left = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_right = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === initPokemonList.length - 1 ? selectedItemIndex : selectedItemIndex + 1)
  },[])

  const press_a = useCallback(async () => {
    const index = initPokemonList[selectedItemIndex].index;
    return await spawnPlayer(index);
  }, [selectedItemIndex]);

  const press_b = () => { return;}

  const press_up = () => { return; };
  const press_down = () => { return; };
  const press_start = () => { return; };

  useKeyboardMovement(true, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)



  return (
    <>
      <div className="player-console"> 
        <h1> Select your starting pokemon. <br /><br />Press A to $Spawn with {initPokemonList[selectedItemIndex].name}</h1>
      </div>
      <div className="spawn-player">
        {initPokemonList.map((pokemon, index) => (
          <div 
            key={index}
            className={`menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            <LoadPokemonImage classIndex={pokemon.index} imageType={PokemonImageType.front}/>
            <h1>{pokemon.name}</h1>
          </div>
        ))}
      </div>

      <style>
      {`
        .spawn-player {
          display: flex;
          flex-direction: row;
          justify-content: space-between;
          background-color: white;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          width: 100%;
          height: auto;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
          top: 100px;
          position: absolute; /* Add this to allow z-index */
          z-index: 10; /* Add this to set the z-index */
        }
        
        .menu-item {
          display: flex;
          flex-direction: column;
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