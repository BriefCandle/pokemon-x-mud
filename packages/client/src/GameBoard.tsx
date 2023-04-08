import { useEffect, useRef, useState } from "react";
import { useMUD } from "./mud/MUDContext";

import { getComponentEntities, getComponentValueStrict, getEntitiesWithValue, getComponentValue, Has, ComponentValue, EntityID } from "@latticexyz/recs";
import { RenderMap } from "./components/Map/RenderMap";
import { RenderMenu } from "./components/Menu/RenderMenu";
import { RenderBattle } from "./components/Battle/RenderBattle";

import { ActiveComponent, useActiveComponent } from "./useActiveComponent";
import { RenderTeam } from "./components/Menu/RenderTeam";

export const GameBoard = () => {

  const {
    components: { Player, Team, TeamBattle },
    api: { spawnPlayer },
    playerEntityId,
    playerEntity,
  } = useMUD();

  const canSpawn = getComponentValue(Player, playerEntity)?.value !== true;

  const teamIndexes = getEntitiesWithValue(Team, {value: playerEntityId} as ComponentValue<{value: any}>)?.values();
  const teamIndex = teamIndexes.next().value;
  const battleID = getComponentValue(TeamBattle, teamIndex)?.value;
  console.log("isBattle", battleID)

  const { activeComponent, setActive } = useActiveComponent();

  useEffect(() => {
    // setActive(ActiveComponent.map);
    if (battleID === undefined) setActive(ActiveComponent.map);
    else setActive(ActiveComponent.battle);
  }, []);
      
  
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
      
      { activeComponent == ActiveComponent.battle || activeComponent == ActiveComponent.battlePlayerAction?
        <RenderBattle setActive={setActive} activeComponent={activeComponent} battleID={battleID} /> : null}

    </div>
  )
}
