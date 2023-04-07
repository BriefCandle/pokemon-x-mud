export enum TerrainType {
  None,
  Path,
  Gravel,
  Grass,
  Flower,
  GrassTall,    // encounter
  TreeShort,    // obstruction
  TreeTall,     // obstruction
  Water,
  Boulder,      // obstruction
  Nurse,        // nurse, obstruction
  PC,           // PC, obstruction
  Spawn,        // Spawn, obstruction
  LevelCheck1 // 10
  // LevelCheck2,  // 20
  // LevelCheck3,  // 30
  // LevelCheck4,  // 30
  // LevelCheck5   // 30
}

export type TerrainConfig = {
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
  [TerrainType.Nurse]: {
    tile00: "",
    tile10: "",
    tile01: "",
    tile11: ""
  },
  [TerrainType.PC]: {
    tile00: "pc00",
    tile10: "pc10",
    tile01: "pc01",
    tile11: "pc11"
  },
  [TerrainType.Spawn]: {
    tile00: "",
    tile10: "",
    tile01: "",
    tile11: ""
  },
  [TerrainType.LevelCheck1]: {
    tile00: "level_check",
    tile10: "level_check",
    tile01: "level_check",
    tile11: "level_check"
  },
};

export const parcelWidth = 5;
export const parcelHeight = 5;

export const terrainWidth = 40;
export const terrainHeight = 40;

export enum InteractTerrainType {
  None,
  Nurse,
  PC,
  Spawn
}