import { PokemonClasses } from "./PokemonClasses";
import { useEffect, useRef } from "react";
import { useMUD } from "./mud/MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { useParcels } from "./useParcels";
import { parcelHeight, parcelWidth, terrainWidth, terrainHeight } from "./enum/terrainTypes";
import { images } from "./CreateParcel";

export const GameBoard = () => {

  const {
    components: { Position },
    api: { crawlTo },
    systems,
    world,
    playerEntity,
  } = useMUD();

  // console.log(world)
  const playerPosition = useComponentValue(Position, playerEntity);

  useKeyboardMovement();

  // makes player always center of the map
  // const mapRef = useRef(null);
  // useEffect(() => {
  //   const mapContainer = mapRef.current;
  //   const { clientWidth, clientHeight } = mapContainer;
  //   // calculate the position of the entity relative to the center of the map    
  //   const xCenter = clientWidth / 2;
  //   const yCenter = clientHeight / 2;
  //   const xEntity = playerPosition?.x * element_width; // assuming each cell is 32px wide
  //   const yEntity = playerPosition?.y * element_width; // assuming each cell is 32px high
  //   const xTranslate = xCenter - xEntity;
  //   const yTranslate = yCenter - yEntity;
  //   // apply the transform to the map
  //   mapContainer?.style.setProperty('transform', `translate(${xTranslate}px, ${yTranslate}px)`);
  // }, [playerPosition])

  const parcels = useParcels();

  const xValues = parcels.map(parcel => parcel.x_parcel);
  const yValues = parcels.map(parcel => parcel.y_parcel);
  const maxX = Math.max(...xValues);
  const maxY = Math.max(...yValues);
  const minX = Math.min(...xValues);
  const minY = Math.min(...yValues);


  const renderParcel = (parcel, index) => {
    const rows = new Array(2).fill(null);
    const columns = new Array(2).fill(null);
    const { x_parcel, y_parcel, parcel_info} = parcel;
    const terrain = parcel_info.map((info, t_index) => (
      <div key={t_index} 
      style={{position: 'absolute', left: terrainWidth*info.x, top: terrainHeight* info.y,
              width: terrainWidth, height: terrainHeight, backgroundColor: 'blue',
              display: 'flex', flexDirection: 'row', flexWrap: 'wrap', }}
      >
        {rows.map((y, rowIndex) =>
          columns.map((x, columnIndex) => {
            const imageSrc = images[info.type["tile" + columnIndex.toString() + rowIndex.toString()]]
            return (
              <img key={`${index},${t_index},${columnIndex},${rowIndex}`}
              className="flex cursor-pointer hover:ring" src={imageSrc}  
              style={{gridColumn: x + 1, gridRow: y + 1, width:terrainWidth/2}}
              /> 
            )}
          )
        )}
      </div>
    ))
    return (
      <div key={index} style={{position: 'relative', left: x_parcel*parcelWidth*terrainWidth, top: y_parcel*parcelHeight*terrainHeight}}>
        {terrain}
      </div>
    )
  }

  return (
      <div>
      {parcels.map(renderParcel)}
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