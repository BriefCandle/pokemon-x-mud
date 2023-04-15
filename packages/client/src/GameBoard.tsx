import { useEffect, useRef, useState } from "react";
import { useMUD } from "./mud/MUDContext";

import { getComponentEntities, getComponentValueStrict, getEntitiesWithValue, getComponentValue, Has, ComponentValue, EntityID, HasValue } from "@latticexyz/recs";
import { RenderMap } from "./components/Map/RenderMap";
import { RenderMenu } from "./components/Menu/RenderMenu";
import { RenderBattle } from "./components/Battle/RenderBattle";
import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { ActiveComponent, useActiveComponent } from "./useActiveComponent";
import { RenderTeam } from "./components/Menu/RenderTeam";
import { BattleProvider } from "./mud/utils/BattleContext";
import { MapProvider } from "./mud/utils/MapContext";
import { BattleLoadingScreen } from "./components/Battle/BattleLoadingScreen";
import { SpawnPlayer } from "./components/Spawn/SpawnPlayer";
import { RespawnPlayer } from "./components/Spawn/RespawnPlayer";

export const GameBoard = () => {

  const {
    components: { Player, Team, TeamBattle, Position, BattleOffer },
    api: { spawnPlayer, respawn },
    playerEntityId,
    playerEntity,
  } = useMUD();

  const canSpawn = useComponentValue(Player, playerEntity)?.value !== true;
  const canRespawn = useComponentValue(Position, playerEntity) ? false :true ;

  const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  const teamIndex = teamIndexes.next().value;
  const battleID = useComponentValue(TeamBattle, teamIndex)?.value;

  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (battleID !== undefined) {
      console.log("test")
      setIsLoading(true);
    }
  },[battleID])

  const handleTransitionComplete = () => {
    setIsLoading(false);
  };

  
  return (
    <>
    <div style={{ position: "relative", width: "500px", height: "350px", overflow: "hidden", border: "solid white 1px"}}>
      {canSpawn ? <SpawnPlayer /> : null}
      {!canSpawn && canRespawn? <RespawnPlayer /> : null}
      
      {/* {isLoading && <BattleLoadingScreen onTransitionComplete={handleTransitionComplete}/>} */}

      { !canSpawn && !canRespawn && !battleID ? 
        <MapProvider>
          <RenderMap/>
        </MapProvider> : null}
      
      { battleID ?
        <BattleProvider battleID={battleID} playerEntityId={playerEntityId}>
          <RenderBattle /> 
        </BattleProvider>: null}

    </div>
    <style>
      {`
        .player-console {
          height: 100px;
          position: absolute;
          width: 100%;
          bottom: 0;
          background-color: white;
          color: black;
          display: flex;
          justify-content: space-between;
          z-index: 10;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
        }
      `}
    </style>
    </>

  )
}
