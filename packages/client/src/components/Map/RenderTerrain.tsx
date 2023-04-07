import { parcelHeight, parcelWidth, terrainWidth, terrainHeight } from "../../enum/terrainTypes";
import { images } from "../../CreateParcel";

export const RenderTerrain = (prop: { terrainValue: any; t_index: any; }) => {
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