export enum TerrainType {
  None,
  Path ,
  Grass,
  Gravel,
  Flower,
  GrassTall,
  GrassRustle,
  TreeShort,
  TreeTall,
  Water,
  Boulder,
}

type TerrainConfig = {
  tile00: string;
  tile10: string;
  tile01: string;
  tile11: string;
};

export const terrainTypes: Record<TerrainType, TerrainConfig> = {
  [TerrainType.None]:{
    tile00: "",
    tile10: "",
    tile01: "",
    tile11: ""
  },
  [TerrainType.Path]: {
    tile00: "path",
    tile10: "path",
    tile01: "path",
    tile11: "path"
  },
  [TerrainType.Gravel]: {
    tile00: "gravel",
    tile10: "gravel",
    tile01: "gravel",
    tile11: "gravel"
  },
  [TerrainType.Grass]: {
    tile00: "grass",
    tile10: "grass",
    tile01: "grass",
    tile11: "grass"
  },
  [TerrainType.Flower]: {
    tile00: "grass",
    tile10: "flower",
    tile01: "flower",
    tile11: "grass"
  },
  [TerrainType.GrassTall]: {
    tile00: "grass_tall",
    tile10: "grass_tall",
    tile01: "grass_tall",
    tile11: "grass_tall"
  },
  [TerrainType.GrassRustle]: {
    tile00: "grass_rustle00",
    tile10: "grass_rustle10",
    tile01: "grass_rustle00",
    tile11: "grass_rustle10"
  },
  [TerrainType.TreeShort]: {
    tile00: "tree_short00",
    tile10: "tree_short10",
    tile01: "tree_short01",
    tile11: "tree_short11"
  },
  [TerrainType.TreeTall]: {
    tile00: "",
    tile10: "",
    tile01: "",
    tile11: ""
  },
  [TerrainType.Water]: {
    tile00: "water",
    tile10: "water",
    tile01: "water",
    tile11: "water"
  },
  [TerrainType.Boulder]: {
    tile00: "🪨",
    tile10: "",
    tile01: "",
    tile11: ""
  },
};

export const parcelWidth = 5;
export const parcelHeight = 5;

export const terrainWidth = 40;
export const terrainHeight = 40;