import { useEffect, useRef, useState } from "react";
import { useMUD } from "./mud/MUDContext";

import { getComponentEntities, getComponentValueStrict, getComponentValue, Has } from "@latticexyz/recs";
import { RenderMap } from "./components/Map/RenderMap";
import { RenderMenu } from "./components/Menu/RenderMenu";
import { RenderPC } from "./components/PC/RenderPC";

import { ActiveComponent, useActiveComponent } from "./useActiveComponent";
import { RenderTeam } from "./components/Menu/RenderTeam";
import { PCOwned } from "./components/PC/PCOwned";

export const GameBoard = () => {

  const {
    components: { Player },
    api: { spawnPlayer },
    playerEntity,
  } = useMUD();

  // const teamID = 
  // const isBattle = getComponentValue(Battle, teamID)?.value !== true;
  const { activeComponent, setActive } = useActiveComponent();
  console.log(activeComponent)
  useEffect(() => {
    setActive(ActiveComponent.map);
  }, []);
      
  const canSpawn = getComponentValue(Player, playerEntity)?.value !== true;

  return (
    <div style={{ position: "relative", width: "500px", height: "400px", overflow: "hidden", border: "solid white 1px"}}>
      {canSpawn? <button onClick={spawnPlayer}>Spawn</button> : null}
      
      { activeComponent == ActiveComponent.map || activeComponent == ActiveComponent.menu ||
      
      activeComponent == ActiveComponent.pc || activeComponent == ActiveComponent.pcTeam || 
      activeComponent == ActiveComponent.pcTeamMenu || activeComponent == ActiveComponent.pcTeamSelect || 
      activeComponent == ActiveComponent.pcOwned || activeComponent == ActiveComponent.pcOwnedMenu ?
        (<RenderMap setActive={setActive} activeComponent={activeComponent} />) : null}

      {/* { activeComponent == ActiveComponent.menu ?
        <RenderMenu setActive={setActive} activeComponent={activeComponent} /> : null} */}

      { activeComponent == ActiveComponent.team || activeComponent == ActiveComponent.teamPokemonMenu ||
        activeComponent == ActiveComponent.teamPokemon || activeComponent == ActiveComponent.teamSwitch ? 
        <RenderTeam setActive={setActive} activeComponent={activeComponent} /> : null}

      {/* { activeComponent == ActiveComponent.pc || activeComponent == ActiveComponent.pcTeam || 
        activeComponent == ActiveComponent.pcTeamMenu || activeComponent == ActiveComponent.pcTeamSelect || 
        activeComponent == ActiveComponent.pcOwned || activeComponent == ActiveComponent.pcOwnedMenu ?
        (<PCOwned setActive={setActive} activeComponent={activeComponent} />) : null} */}
      

    </div>
  )
}
