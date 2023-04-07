import { useState } from "react";

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
  "battle"
}

export const useActiveComponent = () => {
  const [activeComponent, setActiveComponent] = useState<ActiveComponent | null>(null);

  const setActive = (component: any) => {
    setActiveComponent(component);
  };

  return {activeComponent, setActive};
}