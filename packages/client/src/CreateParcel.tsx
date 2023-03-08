import { useCallback, useEffect, useState } from "react";
import { useMUD } from "./mud/MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { useParcels } from "./useParcels";
import { TerrainConfig, terrainTypes, TerrainType, parcelHeight, parcelWidth, terrainWidth, terrainHeight } from "./enum/terrainTypes";
import flower from "./assets/tiles/flower.gif"
import grass_rustle00 from "./assets/tiles/grass_rustle00.png"
import grass_rustle10 from "./assets/tiles/grass_rustle10.png"
import grass_tall from "./assets/tiles/grass_tall.png";
import grass from "./assets/tiles/grass.png";
import gravel from "./assets/tiles/gravel.png";
import path from "./assets/tiles/path.png";
import tree_short00 from "./assets/tiles/tree_short00.png";
import tree_short01 from "./assets/tiles/tree_short01.png";
import tree_short10 from "./assets/tiles/tree_short10.png";
import tree_short11 from "./assets/tiles/tree_short11.png";
import water from "./assets/tiles/water.gif";
import none from "./assets/tiles/none.png";
import { ethers } from "ethers";

export const images = {flower, grass_rustle00, grass_rustle10, grass_tall, grass, gravel, path, tree_short00,
  tree_short01, tree_short10, tree_short11, water, none}

export const CreateParcel = () => {
  const {
    components: { Position },
    systems,
    world,
    playerEntity,
  } = useMUD();

  const parcels = useParcels();

  const max_row = 6;
  const max_col = 6;

  type Parcel = {
    x_parcel: number;
    y_parcel: number;
    parcel_info: {
      [key: number]: {
        x: number;
        y: number;
        value: number;
        type: TerrainConfig;
      }
    }
  }
  // to render terrain in every empty parcel
  const emptyTerrainValues: {[key: number]: any} = {}
  for (let y = 0; y < parcelHeight; y++) {
    for (let x = 0; x < parcelWidth; x++)  {
      const value = 0;
      const type = terrainTypes[value as TerrainType];
      const terrainNo = y * parcelWidth + x;
      emptyTerrainValues[terrainNo] = { x, y, value, type };
    }
  }
  const rows = Array.from({ length: max_row }, (_, i) => i);
  const columns = Array.from({ length: max_col }, (_, i) => i);
  const newParcels: {[key: number]: Parcel} = {}
  for (let row of rows) {
    for (let col of columns) {
      const found = parcels.some(coord => {
        return coord.x_parcel == col && coord.y_parcel == row
      })
      if (!found) {
        const parcelNo = row * max_col + col;
        newParcels[parcelNo] = { x_parcel: col, y_parcel: row, parcel_info: emptyTerrainValues }
      }
  }}
  const [newMap, setNewMap] = useState(newParcels)

  const renderNewParcel = useCallback((newParcel: Parcel, index: number) => {
    const { x_parcel, y_parcel, parcel_info} = newParcel;
    const parcelNo = y_parcel * max_col + x_parcel;
    return (
      <div key={index} style={{position: 'relative', left: x_parcel*parcelWidth*terrainWidth, top: y_parcel*parcelHeight*terrainHeight}}>
        {Object.values(parcel_info).map((terrain, index)=> (
          <RenderTerrain terrainValue={terrain} t_index={index} parcel_no={parcelNo}/>
        ))}
      </div>
    )
  }, [newMap])

  const renderParcel = (parcel, index) => {
    const { x_parcel, y_parcel, parcel_info} = parcel;
    const parcelNo = y_parcel * max_col + x_parcel;
    return (
      <div key={`${x_parcel},${y_parcel}`} style={{position: 'relative', left: x_parcel*parcelWidth*terrainWidth, top: y_parcel*parcelHeight*terrainHeight}}>
        {parcel_info.map((terrain, index) => (
          <RenderTerrain key={index} terrainValue={terrain} t_index={index} parcel_no={parcelNo} />
        ))}
      </div>
    )
  }

  const [selectedTerrain, setTerrain] = useState({parcel_no: 0, terrainNo: 0})

  const setMap = (value: any) => {
    const {parcel_no, terrainNo} = selectedTerrain
    const updatedValue = {
      ...newMap,
      [parcel_no]: {
        ...newMap[parcel_no],
        parcel_info: {
          ...newMap[parcel_no].parcel_info,
          [terrainNo]: {
            ...newMap[parcel_no].parcel_info[terrainNo],
            value: value,
            type: terrainTypes[value as TerrainType]
          }}}}
    setNewMap(updatedValue)
  }

  useEffect(() => {
    const listener = (e: KeyboardEvent) => {
      if(e.key === 'n') setMap(0) // none
      if(e.key === 'p') setMap(1) // path
      if(e.key === 'v') setMap(2) // gravel
      if(e.key === 'g') setMap(3) // grass
      if(e.key === 'f') setMap(4) // flower
      if(e.key === 'l') setMap(5) // grasstall
      if(e.key === 's') setMap(6) // treeshort
      if(e.key === 't') setMap(7) // treetall
      if(e.key === 'w') setMap(8) // water
      if(e.key === 'b') setMap(9) // bolder
    }
    window.addEventListener("keydown", listener);
    return () => window.removeEventListener("keydown", listener);
  })

  // useEffect(() => {
  //   const listener = (e: MouseEvent) => {
  //     e.preventDefault();
  //     console.log('test')
  //   }
  //   window.addEventListener('contextmenu', listener);    
  //   return () => window.removeEventListener('contextmenu', listener);
  // }, []);

  const [showMessage, setShowMessage] = useState(999999999);

  const handleOpenMessage = (parcel_no: number) => {
    setShowMessage(parcel_no);
  }

  function handleCloseMessage() {
    setShowMessage(999999999); // too lazy to make a new state
  }

  const MessageWindow = () => {
    return (
      <div>
        {showMessage!=999999999 && (
          <div style={{ 
            position: "fixed", 
            top: "50%", 
            left: "50%", 
            transform: "translate(50%, 50%)",
            backgroundColor: "black", 
            border: "1px solid black", 
            padding: "20px", 
            zIndex: "9999"
          }}>
            <button onClick={submitParcel}>Submit Parcel NO {showMessage}</button><br />
            <button onClick={handleCloseMessage}>Close</button>
          </div>
        )}
      </div>
    );
  }

  const submitParcel = async () => {
    const parcel_no: number = showMessage
    const {x_parcel, y_parcel, parcel_info}: Parcel = newMap[parcel_no]
    const numbers = Object.values(parcel_info).map(obj => obj.value)
    const bytes = new Uint8Array(numbers.length);
    numbers.forEach((number, index) => bytes.set([number], index))
    const tx = await systems["system.CreateParcel"].executeTyped(x_parcel, y_parcel, bytes);
    await tx.wait()
  }


  // newParcels = parcelNo: {x_parcel, y_parcel, parcel_info: {terrainNo: {x, y, value, type}}}
  const RenderTerrain = (prop: { terrainValue: any; t_index: any; parcel_no: any; }) => {
    const {terrainValue, t_index, parcel_no} = prop
    const handleClick = (e) => {
      if (e.button === 0){
        const terrainNo = terrainValue.y * parcelWidth + terrainValue.x;
        setTerrain({parcel_no: parcel_no, terrainNo: terrainNo});}
      else if (e.button === 2) {
        e.preventDefault();
        handleOpenMessage(parcel_no)
        // submitParcel(parcel_no)
      }
    }
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
      <div key={t_index} className="flex cursor-pointer hover:bg-blue-100" onMouseDown={handleClick}
          style={{position: 'absolute', left: terrainWidth*terrainValue.x, top: terrainHeight* terrainValue.y,
              width: terrainWidth, height: terrainHeight,
              display: 'flex', flexDirection: 'row', flexWrap: 'wrap', }}>
        {tiles}
      </div>
    )
  }

  return (
    <div>
      <div>
      {parcels.map(renderParcel)}
      {Object.values(newMap).map(renderNewParcel)}
      <MessageWindow />
      </div>
    </div>
  )
}