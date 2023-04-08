import { useState } from "react";

// mainly for user input
export enum ActiveComponent {
  "map",
  "pc",
  "pcTeam",
  "pcTeamMenu",
  "pcTeamSelect",
  "pcOwned",
  "pcOwnedMenu",
  "pcPokemon",
  "pcSwitch",
  "menu",
  "team",
  "teamSwitch",
  "teamPokemonMenu",
  "teamPokemon",
  "pokemonClass",
  "battle",
  "battlePlayerAction",
  "battlePlayerTarget",
  "battlePlayerWait"
}

export const useActiveComponent = () => {
  const [activeComponent, setActiveComponent] = useState<ActiveComponent | null>(null);

  const setActive = (component: any) => {
    setActiveComponent(component);
  };

  return {activeComponent, setActive};
}