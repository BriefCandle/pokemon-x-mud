pragma solidity ^0.8.13;

import { PokemonScript } from "../PokemonScript.s.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { CreateParcelSystem, ID as CreateParcelSystemID } from "../../src/systems/CreateParcelSystem.sol";

import { Parcel, parcelWidth, parcelHeight } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/CreateParcel00.s.sol:CreateParcel00Script --rpc-url http://localhost:8545 --broadcast

contract CreateParcelScript is PokemonScript {

  int32 x_p;
  int32 y_p;

  TerrainType P = TerrainType.Path;
  TerrainType G = TerrainType.Grass;
  TerrainType V = TerrainType.Gravel;
  TerrainType F = TerrainType.Flower;
  TerrainType L = TerrainType.GrassTall;
  TerrainType S = TerrainType.TreeShort;
  TerrainType T = TerrainType.TreeTall;
  TerrainType W = TerrainType.Water;
  TerrainType B = TerrainType.Boulder;

  TerrainType N = TerrainType.Nurse;
  TerrainType PC = TerrainType.PC;
  TerrainType LC = TerrainType.LevelCheck1;

  TerrainType[parcelHeight][parcelWidth] map;

  function convertTerrainArrayToBytes(TerrainType[parcelHeight][parcelWidth] memory map) internal pure returns( bytes memory terrain) {
    terrain = new bytes(parcelWidth * parcelHeight);
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        TerrainType terrainType = map[j][i];
        terrain[(j * parcelWidth) + i] = bytes1(uint8(terrainType));
      }
    }
  }

  function createParcel(int32 x_parcel, int32 y_parcel, bytes memory terrain) internal {
    CreateParcelSystem(system(CreateParcelSystemID)).executeTyped(x_parcel,y_parcel,terrain);
  }
  
}



      // [O, O, O, O, O, O, T, O, O, O],
      // [O, O, T, O, O, O, O, O, T, O],
      // [O, T, T, T, T, O, O, O, O, O],
      // [O, O, T, T, T, T, O, O, O, O],
      // [O, O, O, O, T, T, O, O, O, O],
      // [O, O, O, B, B, O, O, O, O, O],
      // [O, T, O, O, O, B, B, O, O, O],
      // [O, O, T, T, O, O, O, O, O, T],
      // [O, O, T, O, O, O, O, T, T, T],
      // [O, O, O, O, O, O, O, T, T, T]

      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [T, T, T, T, T, T, T, T, T, T],
      // [B, B, B, B, T, T, T, T, T, T]