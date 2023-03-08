import { useComponentValue } from "@latticexyz/react";
import { getComponentEntities, getComponentValue } from "@latticexyz/recs";
import { useMUD } from "./mud/MUDContext";
import { useEffect } from "react";
import { ethers } from "ethers";
import { terrainTypes, TerrainType, parcelHeight, parcelWidth} from "./enum/terrainTypes";


export const useParcels = () => {
  const {
    components: { Parcel},
  } = useMUD();

  // const positionIndexes = getComponentEntities(Position);
  // console.log(positionIndexes)

  const parcelIndexes = getComponentEntities(Parcel);
  if (parcelIndexes == null) {
    throw new Error("game config not set or not ready, only use this hook after loading state === LIVE");
  }

  const parcels = Array.from(parcelIndexes, (index)=> {
    const parcel = getComponentValue(Parcel, index)
    // this is the relative x, y within a parcel
    const { x, y, terrain } = parcel; 
    // use offset to find absolute coords
    // const xOffset = parcelWidth * x;
    // const yOffset = parcelHeight * y;

    const terrainValues = Array.from(ethers.utils.toUtf8Bytes(terrain)).map((value, index)=>({
      x: index % parcelWidth,
      y: Math.floor(index/parcelWidth),
      value,
      type: value in TerrainType ? terrainTypes[value as TerrainType]: null,
    }))
    
    return {
      x_parcel: x,
      y_parcel: y,
      parcel_info: terrainValues}
  })




  return parcels
};