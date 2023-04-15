import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
// import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useParcels } from "./useParcels";
import { parcelHeight, parcelWidth, terrainWidth, terrainHeight, InteractTerrainType } from "../../enum/terrainTypes";
import { getComponentEntities, getComponentValueStrict, getComponentValue, getEntitiesWithValue, Has, HasValue, ComponentValue, Type, EntityID, EntityIndex } from "@latticexyz/recs";
import ethan_up from "../../assets/player/ethan_up.png";
import ethan_down from "../../assets/player/ethan_down.png";
import ethan_left from "../../assets/player/ethan_left.png";
import ethan_right from "../../assets/player/ethan_right.png";
import { RenderTerrain } from "./RenderTerrain";
import { ActiveComponent, useActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { RenderMenu } from "../Menu/RenderMenu";
import { PCOwned } from "../PC/PCOwned";
import { OtherPlayerMenu } from "../OtherPlayer/OtherPlayerMenu";
import { RenderTeam } from "../Menu/RenderTeam";
import { OfferorWait } from "../OtherPlayer/OfferorWait";
import { OffereeMenu } from "../OtherPlayer/OffereeMenu";
import { TerrainConsole } from "./TerrainConsole";
import { useMapContext } from "../../mud/utils/MapContext";

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

const getEthanPNG = (direction: PlayerDirection) : any => {
  switch (direction) {
    case PlayerDirection.Up:
      return ethan_up;
    case PlayerDirection.Down:
      return ethan_down;
    case PlayerDirection.Left:
      return ethan_left;
    case PlayerDirection.Right:
      return ethan_right;
  }
}

export const RenderMap = () => {

  const {
    components: { Position, Player, TerrainPC, TerrainNurse, TerrainSpawn, BattleOffer, Team },
    api: { crawlBy },
    playerEntity,
    playerEntityId
  } = useMUD();

  const { activeComponent, setActive, interactCoord, setInteractCoord, thatPlayerIndex, setThatPlayerIndex} = useMapContext();
  
  const playerPosition = useComponentValue(Position, playerEntity);

  const [playerDirection, setPlayerDirection] = useState<PlayerDirection>(PlayerDirection.Up);


  // ------ battle offer ------
  const isOfferor = useComponentValue(BattleOffer, playerEntity)?.value !== undefined;
  const isOfferee = useEntityQuery([HasValue(BattleOffer, {value: playerEntityId})]).length !==0;

  useEffect(() => {
    setActive(ActiveComponent.map);
  },[]);
  
  useEffect(() => {
    if (isOfferor && activeComponent == ActiveComponent.map) return setActive(ActiveComponent.offerorWait)
    if (isOfferee && activeComponent == ActiveComponent.map) return setActive(ActiveComponent.offereeMenu)
  }, [isOfferor, isOfferee, activeComponent]);


  // ------ key inputs ------
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
  
  const press_a = useCallback(() => {
    if (playerPosition !== undefined && playerDirection !== undefined) {
      const coord = getInteractCoord(playerPosition, playerDirection)
      console.log("coord", coord)
      setInteractCoord(coord)
      setActive(ActiveComponent.terrainConsole)
    }
  },[interactCoord, playerDirection, playerPosition])

  
  const press_b = () => {return;}
  const press_start = () => setActive(ActiveComponent.menu);

  useKeyboardMovement(activeComponent == ActiveComponent.map, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)
  
  
  // ------ other players ------
  useObservableValue(Position.update$)
  
  const otherPlayers = useEntityQuery([Has(Player), Has(Position)])
    .filter((entity) => entity != playerEntity)
    .map((entity) => {
      const position = getComponentValueStrict(Position, entity);
      return {entity, position}
  })
  
  // ------ makes player always center of the map ------
  const mapRef = useRef(null);
  useEffect(() => {
    if (playerPosition){      
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
      mapContainer?.style.setProperty('transform', `translate(${xTranslate}px, ${yTranslate}px)`);}
  }, [playerPosition])
  
  const parcels = useParcels();

  const RenderPlayer = (props: {entity: any, player_position: {x: number, y:number}, 
    parcel_position: {x:number, y:number}, terrain_position: {x:number, y:number}}) => {
    const {entity, player_position, parcel_position, terrain_position} = props;
    
    const x_offset = parcel_position.x * parcelWidth;
    const y_offset = parcel_position.y * parcelHeight;
    const x_player = player_position.x - x_offset;
    const y_player = player_position.y - y_offset;
    
    return (
      <>
        {x_player === terrain_position.x && y_player === terrain_position.y ? 
          <div style={{zIndex: 1, position: 'absolute'}} key={`${entity},${x_player}, ${y_player}}`}>
            <img style={{width: '45px', height: "35px"}} src={getEthanPNG(playerDirection)} alt="" />
          </div>  : null}
      </>
    )
  }

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

    // const player_x = playerPosition?.x - x_offset;
    // const player_y = playerPosition?.y - y_offset;
    
    return (
      <div key={`${x_parcel},${y_parcel}`} style={{position: 'relative', left: x_parcel*parcelWidth*terrainWidth, top: y_parcel*parcelHeight*terrainHeight}}>
        {parcel_info.map((terrain: any, index) => (
          <div style={{position: 'absolute', left: terrainWidth*terrain.x, top: terrainHeight* terrain.y,
          width: terrainWidth, height: terrainHeight,
          display: 'flex', flexDirection: 'row', flexWrap: 'wrap',
          alignItems: 'center', justifyContent: 'center'
          }}>
            <RenderTerrain key={index} terrainValue={terrain} t_index={index} />

            { playerPosition ? 
              <RenderPlayer entity={playerEntity} player_position={{x: playerPosition?.x, y: playerPosition?.y}} 
              parcel_position={{x: x_parcel, y: y_parcel}} terrain_position={{x: terrain.x, y: terrain.y}}/> : null
            }

            {/* { player_x === terrain.x && player_y === terrain.y ? 
              <div style={{zIndex: 1, position: 'absolute'}} key={`${player_x}, ${player_y}}`}>
                <img style={{width: '25px'}} src={ethan} alt="" />
              </div> 
              : null
            } */}

            { otherPlayersHere.length != 0 ? otherPlayersHere.filter((p) => 
              p.position.x == x_offset+terrain.x && p.position.y == y_offset+terrain.y).map((p) => 
                (<div style={{zIndex: 1, position: 'absolute'}} key={p.entity}>
                  <img style={{width: '45px', height: "35px"}} src={ethan_down} alt="" />
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
      { activeComponent == ActiveComponent.offerorWait ?
        <OfferorWait /> : null}
    
      { activeComponent == ActiveComponent.offereeMenu ?
        <OffereeMenu /> : null}

      { activeComponent == ActiveComponent.otherPlayerMenu ?
        <OtherPlayerMenu/> : null
      }


      { activeComponent == ActiveComponent.pc || activeComponent == ActiveComponent.pcTeam || 
        activeComponent == ActiveComponent.pcTeamMenu || activeComponent == ActiveComponent.pcTeamSelect || 
        activeComponent == ActiveComponent.pcOwned || activeComponent == ActiveComponent.pcOwnedMenu 
        ?
        (<PCOwned />) : null}
      

      { activeComponent == ActiveComponent.team || activeComponent == ActiveComponent.teamPokemonMenu ||
        activeComponent == ActiveComponent.teamPokemon || activeComponent == ActiveComponent.teamSwitch ? 
        <RenderTeam /> : null}


      { activeComponent == ActiveComponent.menu ?
        <RenderMenu /> : null}


      { activeComponent == ActiveComponent.terrainConsole ? 
        <TerrainConsole otherPlayers={otherPlayers} /> : null}
      

      {      
        <div ref={mapRef}>
          {parcels.map(RenderParcel)}
        </div>}
    </>
  )
  
}
