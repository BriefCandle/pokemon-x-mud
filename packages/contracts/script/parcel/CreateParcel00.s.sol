pragma solidity ^0.8.13;

import "../../lib/forge-std/src/Script.sol";
import { Parcel, parcelWidth, parcelHeight } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/CreateParcel00.s.sol:CreateParcel00Script --rpc-url http://localhost:8545 --broadcast

contract CreateParcel00Script is Script {

  address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
  address CreateParcelSystem = 0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf;
  int32 x_p = 0;
  int32 y_p = 0;

  
  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    TerrainType P = TerrainType.Path;
    TerrainType G = TerrainType.Grass;
    TerrainType V = TerrainType.Gravel;
    TerrainType F = TerrainType.Flower;
    TerrainType L = TerrainType.GrassTall;
    TerrainType S = TerrainType.TreeShort;
    TerrainType T = TerrainType.TreeTall;
    TerrainType W = TerrainType.Water;
    TerrainType B = TerrainType.Boulder;

    TerrainType[parcelHeight][parcelWidth] memory map = [
      [S, S, S, S, S],
      [S, G, G, G, G],
      [S, G, G, G, G],
      [S, G, G, G, G],
      [S, G, G, G, G]
    ];

    bytes memory terrain = new bytes(parcelWidth * parcelHeight);
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        TerrainType terrainType = map[j][i];
        terrain[(j * parcelWidth) + i] = bytes1(uint8(terrainType));
      }
    }
    // Parcel memory parcel = Parcel(0, 0, terrain);

    ICreateParcelSystem(CreateParcelSystem).executeTyped(x_p,y_p,terrain);

    vm.stopBroadcast();
  }
}

interface ICreateParcelSystem {
// function executeTyped(Parcel memory parcel) external returns (bytes memory);
  function executeTyped(int32 x_p, int32 y_p, bytes memory terrainMap) external returns (bytes memory);
}

interface IWorld {
  function getUniqueEntityId() external view returns (uint256);
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