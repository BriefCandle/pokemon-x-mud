import { parcelHeight, parcelWidth, terrainWidth, terrainHeight } from "../../enum/terrainTypes";


export  const renderParcel = (parcel: any, index: number) => {
  const { x_parcel, y_parcel, parcel_info} = parcel as {x_parcel: number, y_parcel: number, parcel_info:[]};

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
        </div>
      )
      )}
    </div>
  )
}