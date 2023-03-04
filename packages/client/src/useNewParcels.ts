import { useComponentValue } from "@latticexyz/react";
import { getComponentEntities, getComponentValue } from "@latticexyz/recs";
import { useMUD } from "./mud/MUDContext";
import { useEffect } from "react";
import { ethers } from "ethers";
import { terrainTypes, TerrainType, parcelHeight, parcelWidth} from "./enum/terrainTypes";
import { validators } from "tailwind-merge";


export const useNewParcels = () => {
  const {
    components: { Parcel},
  } = useMUD();

  const parcelIndexes = getComponentEntities(Parcel);
  if (parcelIndexes == null) {
    throw new Error("game config not set or not ready, only use this hook after loading state === LIVE");
  }

  // get some big number of rows and columns, dynamic generating later
  const rows = Array.from({ length: 11 }, (_, i) => i);
  const columns = Array.from({ length: 11 }, (_, i) => i);

  const newParcels: { x_parcel: number; y_parcel: number; }[] = [];
  
  Array.from(parcelIndexes, (index)=> {
    const oldParcel = getComponentValue(Parcel, index)
    // this is the relative x, y within a parcel
    const { x, y } = oldParcel; 

    rows.forEach(row => {
      columns.forEach(col => {
        if (row != y || col != x) newParcels.push({x_parcel: col, y_parcel: row})
      })
    })
  })


  return newParcels
};