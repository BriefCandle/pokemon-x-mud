import { useEffect, useRef, useState } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
// import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useParcels } from "./useParcels";
import { parcelHeight, parcelWidth, terrainWidth, terrainHeight, InteractTerrainType } from "../../enum/terrainTypes";
import { getComponentEntities, getComponentValueStrict, getComponentValue, getEntitiesWithValue, Has, ComponentValue, Type } from "@latticexyz/recs";
import ethan from "../../assets/player/ethan.png";
import { RenderTerrain } from "./RenderTerrain";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { RenderMenu } from "../Menu/RenderMenu";
import { PCOwned } from "../PC/PCOwned";

export enum PlayerDirection {
  Up,
  Down,
  Left,
  Right
}

export const getInteractCoord = (coord: {x: number, y: number}, direction: PlayerDirection):{x: number, y: number} => {
  switch (direction) {
    case PlayerDirection.Up:
      return {x: coord.x, y: coord.y-1};
    case PlayerDirection.Down:
      return {x: coord.x, y: coord.y+1};
    case PlayerDirection.Left:
        return {x: coord.x-1, y: coord.y};
    case PlayerDirection.Right:
      return {x: coord.x+1, y: coord.y};
    default:
      return {x: coord.x, y: coord.y};
  }
}

export const RenderMap = (props: {setActive: any, activeComponent: any}) => {
  const {setActive, activeComponent} = props;

  const {
    components: { Position, Player, TerrainPC, TerrainNurse, TerrainSpawn },
    api: { crawlBy },
    playerEntity,
  } = useMUD();

  useObservableValue(Position.update$);
  const playerPosition = useComponentValue(Position, playerEntity);
  const x_coord = playerPosition?.x;
  const y_coord = playerPosition?.y;



  const [playerDirection, setPlayerDirection] = useState<PlayerDirection>();
  const press_up = () => {
    setPlayerDirection(PlayerDirection.Up);
    crawlBy(0, -1);}

  const press_down = () => {
    setPlayerDirection(PlayerDirection.Down);
    crawlBy(0, 1);}

  const press_left = () => {
    setPlayerDirection(PlayerDirection.Left);
    crawlBy(-1, 0);}

  const press_right = () => {
    setPlayerDirection(PlayerDirection.Right);
    crawlBy(1, 0);}
  
  const interactCoord = getInteractCoord(playerPosition, playerDirection)

  const press_a = () => {
    if (x_coord !== undefined && y_coord !== undefined && interactCoord !== undefined) {
      const terrainType = getTerrainType(interactCoord);
      console.log(playerPosition)
      // console.log("terrainType is: ", terrainType);
      switch (terrainType) {
        case InteractTerrainType.PC:
          setActive(ActiveComponent.pcOwned);
          return;
        default:
          return;
      }
    }
  }

  const getTerrainType = (position: {x: number, y: number}): InteractTerrainType => {
    const positionIndex = getEntitiesWithValue(Position, position as ComponentValue<{x: Type.Number, y: Type.Number}>)?.values().next().value;
    if (getComponentValue(TerrainPC, positionIndex)?.value) return InteractTerrainType.PC;
    if ((getComponentValue(TerrainNurse, positionIndex)?.value)) return InteractTerrainType.Nurse;
    if ((getComponentValue(TerrainSpawn, positionIndex)?.value)) return InteractTerrainType.Spawn;
    return InteractTerrainType.None;
  }
  
  const press_b = () => {return;}
  const press_start = () => setActive(ActiveComponent.menu);

  useKeyboardMovement(activeComponent == ActiveComponent.map, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)
    

  const otherPlayers = useEntityQuery([Has(Player), Has(Position)])
    .filter((entity) => entity != playerEntity)
    .map((entity) => {
      const position = getComponentValueStrict(Position, entity);
      return {entity, position}
    })
  
    // makes player always center of the map
    const mapRef = useRef(null);
    useEffect(() => {
      const mapContainer: any = mapRef.current;
      const { clientWidth, clientHeight } = mapContainer;
      // calculate the position of the entity relative to the center of the map    
      const xCenter = clientWidth / 2;
      const yCenter = clientHeight / 2;
      const xEntity = playerPosition?.x * terrainWidth; // assuming each cell is 32px wide
      const yEntity = playerPosition?.y * terrainHeight; // assuming each cell is 32px high
      const xTranslate = xCenter - xEntity;
      const yTranslate = yCenter - yEntity+100;
      // apply the transform to the map
      mapContainer?.style.setProperty('transform', `translate(${xTranslate}px, ${yTranslate}px)`);
    }, [playerPosition])
  

  const parcels = useParcels();

  const RenderParcel = (parcel: any, index: any) => {
    const { x_parcel, y_parcel, parcel_info} = parcel as {x_parcel: number, y_parcel: number, parcel_info:[]};
    const otherPlayersHere = otherPlayers.filter(
      (p) => p.position.x >= x_parcel * parcelWidth &&
             p.position.x < (x_parcel + 1) * parcelWidth &&
             p.position.y >= y_parcel * parcelHeight &&
             p.position.y < (y_parcel + 1) * parcelHeight
    )
    const x_offset = x_parcel * parcelWidth;
    const y_offset = y_parcel * parcelHeight;

    const player_x = playerPosition?.x - x_offset;
    const player_y = playerPosition?.y - y_offset;
    
    return (
      <div key={`${x_parcel},${y_parcel}`} style={{position: 'relative', left: x_parcel*parcelWidth*terrainWidth, top: y_parcel*parcelHeight*terrainHeight}}>
        {parcel_info.map((terrain: any, index) => (
          <div style={{position: 'absolute', left: terrainWidth*terrain.x, top: terrainHeight* terrain.y,
          width: terrainWidth, height: terrainHeight,
          display: 'flex', flexDirection: 'row', flexWrap: 'wrap',
          alignItems: 'center', justifyContent: 'center'
          }}>
            <RenderTerrain key={index} terrainValue={terrain} t_index={index} />

            { player_x === terrain.x && player_y === terrain.y ? 
              <div style={{zIndex: 1, position: 'absolute'}} key={`${player_x}, ${player_y}}`}>
                <img style={{width: '25px'}} src={ethan} alt="" />
              </div> 
              : null
            }

            { otherPlayersHere.length != 0 ? otherPlayersHere.filter((p) => 
              p.position.x == x_offset+terrain.x && p.position.y == y_offset+terrain.y).map((p) => 
                (<div style={{zIndex: 1, position: 'absolute'}} key={p.entity}>
                  <img style={{width: '25px'}} src={ethan} alt="" />
                </div>))
            : null
            }
          </div>
        )
        )}
      </div>
    )
  }

  return (
    <>
      { activeComponent == ActiveComponent.pc || activeComponent == ActiveComponent.pcTeam || 
        activeComponent == ActiveComponent.pcTeamMenu || activeComponent == ActiveComponent.pcTeamSelect || 
        activeComponent == ActiveComponent.pcOwned || activeComponent == ActiveComponent.pcOwnedMenu ?
        (<PCOwned setActive={setActive} activeComponent={activeComponent} pc_coord={interactCoord}/>) : null}

      { activeComponent == ActiveComponent.menu ?
        <RenderMenu setActive={setActive} activeComponent={activeComponent} /> : null}

      <div ref={mapRef}>
        {parcels.map(RenderParcel)}
      </div>
    </>
  )
  
}
