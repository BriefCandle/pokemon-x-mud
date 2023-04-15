import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";



export const RespawnPlayer = () => { 

  const {
    api: {respawn}
  } = useMUD();

  
  // ----- key input functions -----

  const press_left = () => { return; };

  const press_right = () => { return; };

  const press_a = useCallback(async () => {
    return await respawn();
  },[]);

  const press_b = () => { return;}

  const press_up = () => { return; };
  const press_down = () => { return; };
  const press_start = () => { return; };

  useKeyboardMovement(true, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)


  return (
    <>
      <div className="player-console"> 
        <h1> You've been removed from position in dungeon. <br /><br />Press A to $Respawn.</h1>
      </div>
    </>
  )
}