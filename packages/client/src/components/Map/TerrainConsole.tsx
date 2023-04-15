import { ActiveComponent } from "../../useActiveComponent";
import { useMUD } from "../../mud/MUDContext";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { getComponentEntities, getEntitiesWithValue, getComponentValueStrict, getComponentValue, Has, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";
import { PokemonBasicInfoBar } from "../PokemonInstance/PokemonBasicInfoBar";
import { InteractTerrainType } from "../../enum/terrainTypes";
import { useMapContext } from "../../mud/utils/MapContext";

export const TerrainConsole = (props: {otherPlayers: any[]}) => { 
  const {otherPlayers} = props;

  const {setActive, activeComponent, interactCoord, setInteractCoord, setThatPlayerIndex} = useMapContext();
  
  const {
    components: { Position, Team, TeamPokemons, TerrainPC, TerrainNurse, TerrainSpawn, },
    world,
    playerEntityId,
  } = useMUD();

  // const player_teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  // const player_teamIndex = player_teamIndexes.next().value;
  // const isPlayerTeam = player_teamIndex === teamIndex ? true : false;

  // const pokemonIDs = useComponentValue(TeamPokemons, teamIndex)?.value as string[]; //Type.NumberArray
  
  const findPlayerIndex = (position: {x: number, y:number}) => {
    const result = otherPlayers.find((player)=> {
      return player.position.x === position.x && player.position.y === position.y
    })
    return result ? result.entity : null;
  }
  const getTerrainType = (position: {x: number, y: number}): InteractTerrainType => {
    const positionIndex = getEntitiesWithValue(Position, position as ComponentValue<{x: Type.Number, y: Type.Number}>)?.values().next().value;
    if (getComponentValue(TerrainPC, positionIndex)?.value) return InteractTerrainType.PC;
    if ((getComponentValue(TerrainNurse, positionIndex)?.value)) return InteractTerrainType.Nurse;
    if ((getComponentValue(TerrainSpawn, positionIndex)?.value)) return InteractTerrainType.Spawn;
    return InteractTerrainType.None;
  }

  const [printText, setPrintTest] = useState<string>("")
  useEffect(() => {
    setPrintTest("Something here..");
  },[])
  
  // ----- key input functions -----

  const press_up = useCallback(() => {return;},[])

  const press_down = useCallback(() => {return;},[])

  const press_a = () => {
    const playerIndex = findPlayerIndex(interactCoord);
    if (playerIndex !== null) {
      setThatPlayerIndex(playerIndex);
      return setActive(ActiveComponent.otherPlayerMenu)
    } else {
      const terrainType = getTerrainType(interactCoord);
      switch (terrainType) {
        case InteractTerrainType.PC:
          return setActive(ActiveComponent.pcOwned);
        case InteractTerrainType.Nurse:
          return setActive(ActiveComponent.nurse);
        default:
          return;
      }
    }
  };

  const press_b = () => { setActive(ActiveComponent.map);}

  const press_left = () => { return; };
  const press_right = () => { return; };
  const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.terrainConsole, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)



  return (
    <>
      <div className="player-console">
        <h1>{printText}</h1>
      </div>

      <style>
      {`
      `}
      </style>
    </>
  )
}