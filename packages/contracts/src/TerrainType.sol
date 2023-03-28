// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

enum TerrainType {
  None,
  Path,
  Gravel,
  Grass,
  Flower,
  GrassTall, // encounter
  TreeShort, //obstruction
  TreeTall, //obstruction
  Water,
  Boulder //obstruction
}

// levelCheck1: 10, 20, 30, 40, 50
