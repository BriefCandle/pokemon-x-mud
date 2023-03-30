// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

enum TerrainType {
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
  LevelCheck1,  // 10
  LevelCheck2,  // 20
  LevelCheck3,  // 30
  LevelCheck4,  // 30
  LevelCheck5   // 30
}
