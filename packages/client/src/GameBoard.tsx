import { PokemonClasses } from "./components/PokemonClass/PokemonClasses";
import { useEffect, useRef } from "react";
import { useMUD } from "./mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { useParcels } from "./components/Map/useParcels";
import { parcelHeight, parcelWidth, terrainWidth, terrainHeight } from "./enum/terrainTypes";
import { images } from "./CreateParcel";
import { useSpawn } from "./useSpawn";
import { getComponentEntities, getComponentValueStrict, getComponentValue, Has } from "@latticexyz/recs";
import ethan from "./assets/player/ethan.png";


export const GameBoard = () => {

  const {
    components: { Position, Player },
    api: { spawnPlayer },
    playerEntity,
  } = useMUD();

  console.log("test", playerEntity)

  const otherPlayers = useEntityQuery([Has(Player), Has(Position)])
    .filter((entity) => entity != playerEntity)
    .map((entity) => {
      const position = getComponentValueStrict(Position, entity);
      return {entity, position}
    })
  
  // console.log(playerEntity);
  useObservableValue(Position.update$);
  console.log(otherPlayers)
    
  const playerPosition = useComponentValue(Position, playerEntity);
  console.log(playerPosition)

  // const { canSpawn, spawn } = useSpawn();
  const canSpawn = getComponentValue(Player, playerEntity)?.value !== true;
  useKeyboardMovement();

  // makes player always center of the map
  const mapRef = useRef(null);
  // useEffect(() => {
  //   const mapContainer = mapRef.current;
  //   const { clientWidth, clientHeight } = mapContainer;
  //   // calculate the position of the entity relative to the center of the map    
  //   const xCenter = clientWidth / 2;
  //   const yCenter = clientHeight / 2;
  //   const xEntity = playerPosition?.x * terrainWidth; // assuming each cell is 32px wide
  //   const yEntity = playerPosition?.y * terrainHeight; // assuming each cell is 32px high
  //   const xTranslate = xCenter - xEntity;
  //   const yTranslate = yCenter - yEntity+100;
  //   // apply the transform to the map
  //   mapContainer?.style.setProperty('transform', `translate(${xTranslate}px, ${yTranslate}px)`);
  // }, [playerPosition])

  const parcels = useParcels();
  // console.log(parcels)

  // const xValues = parcels.map(parcel => parcel.x_parcel);
  // const yValues = parcels.map(parcel => parcel.y_parcel);
  // const maxX = Math.max(...xValues);
  // const maxY = Math.max(...yValues);
  // const minX = Math.min(...xValues);
  // const minY = Math.min(...yValues);


  const renderParcel = (parcel, index) => {
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
        {parcel_info.map((terrain, index) => (
          <div style={{position: 'absolute', left: terrainWidth*terrain.x, top: terrainHeight* terrain.y,
          width: terrainWidth, height: terrainHeight,
          display: 'flex', flexDirection: 'row', flexWrap: 'wrap',
          alignItems: 'center', justifyContent: 'center'
          }}>
            <RenderTerrain key={index} terrainValue={terrain} t_index={index} />

            { player_x === terrain.x && player_y === terrain.y ? 
              <div style={{zIndex: 1, position: 'absolute'}} key={player_x}>
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

  const RenderTerrain = (prop: { terrainValue: any; t_index: any; }) => {
    const {terrainValue, t_index} = prop
    const rows = new Array(2).fill(null);
    const columns = new Array(2).fill(null);

    const tiles = rows.map((y, rowIndex) =>
      columns.map((x, columnIndex) => {
        const tile_type = "tile" + columnIndex.toString() + rowIndex.toString()
        const tile_prop = terrainValue.type[tile_type]
        const imageSrc = images[tile_prop]

        return (
          <img key={`${t_index},${columnIndex},${rowIndex}`}
          src={imageSrc}  
          // style={{gridColumn: x + 1, gridRow: y + 1, width:terrainWidth/2, grid:"none"}}
          style={{position: 'relative', left: terrainWidth/2*x, top: terrainWidth/2*y,
          width: terrainWidth/2, height: terrainWidth/2,
          display: 'flex', flexDirection: 'row', flexWrap: 'wrap', }}
          /> 
        )}
      )
    )

    return (
      <div key={t_index} 
          style={{
              display: 'flex', flexDirection: 'row', flexWrap: 'wrap', }}
      >
        {tiles}
      </div>
    )
  }

  return (
    <div style={{ width: "500px", height: "400px", overflow: "hidden" }}>
      <div ref={mapRef}>
        {canSpawn? <button onClick={spawnPlayer}>Spawn</button> : null}
        {parcels.map(renderParcel)}
      </div>
    </div>
  )
}

    // <div style={{ width: "400px", height: "400px", overflow: "hidden" }}>
    //   <div className="inline-grid p-2 bg-lime-500" ref={mapRef}>
    //   {rows.map((y) =>
    //     columns.map((x) => (
    //       <div
    //         key={`${x},${y}`}
    //         className="w-8 h-8 flex items-center justify-center cursor-pointer hover:ring"
    //         style={{gridColumn: x + 1, gridRow: y + 1,}}
    //         onClick={(event) => {event.preventDefault();crawlTo(x, y);}}
    //       >
    //         {playerPosition?.x === x && playerPosition?.y === y ? <>🤠</> : null}
    //       </div>
    //     ))
    //   )}
    // </div>
    // </div>