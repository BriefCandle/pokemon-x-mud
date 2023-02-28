export enum PokemonType {
  None = 0, // in the case pokemon has no type2 
  Normal,
  Fight,
  Flying,
  Poison,
  Ground,
  Rock,
  Bug,
  Ghost,
  Steel,
  Fire,
  Water,
  Grass,
  Electric,
  Psychic,
  Ice,
  Dragon,
  Dark
}

type PokemonTypeConfig = {
  name: string;
  icon: string;
};

export const pokemonTypes: Record<PokemonType, PokemonTypeConfig> = {
  [PokemonType.None]: {
    name: "None",
    icon: ""
  },
  [PokemonType.Normal]: {
    name: "Normal",
    icon: ""
  },
  [PokemonType.Fight]: {
    name: "Fight",
    icon: ""
  },
  [PokemonType.Flying]: {
    name: "Flying",
    icon: ""
  },
  [PokemonType.Poison]: {
    name: "Poison",
    icon: ""
  },
  [PokemonType.Ground]: {
    name: "Ground",
    icon: ""
  },
  [PokemonType.Rock]: {
    name: "Rock",
    icon: ""
  },
  [PokemonType.Bug]: {
    name: "Bug",
    icon: ""
  },
  [PokemonType.Ghost]: {
    name: "Ghost",
    icon: ""
  },
  [PokemonType.Steel]: {
    name: "Steel",
    icon: ""
  },
  [PokemonType.Fire]: {
    name: "Fire",
    icon: ""
  },
  [PokemonType.Water]: {
    name: "Water",
    icon: ""
  },
  [PokemonType.Grass]: {
    name: "Grass",
    icon: ""
  },
  [PokemonType.Electric]: {
    name: "Electric",
    icon: ""
  },
  [PokemonType.Psychic]: {
    name: "Psychic",
    icon: ""
  },
  [PokemonType.Ice]: {
    name: "Ice",
    icon: ""
  },
  [PokemonType.Dragon]: {
    name: "Dragon",
    icon: ""
  },
  [PokemonType.Dark]: {
    name: "Dark",
    icon: ""
  },
}


