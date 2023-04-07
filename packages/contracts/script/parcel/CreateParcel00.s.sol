pragma solidity ^0.8.13;

import { CreateParcelScript } from "./CreateParcel.s.sol";
import "../../lib/forge-std/src/Script.sol";
import { Parcel, parcelWidth, parcelHeight } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/CreateParcel00.s.sol:CreateParcel00Script --rpc-url http://localhost:8545 --broadcast

contract CreateParcel00Script is CreateParcelScript {


  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    x_p = 0;
    y_p = 0;

    map = [
      [S, S, S, S, S],
      [S, G, G, G, G],
      [S, G, PC, G, G],
      [S, G, G, G, G],
      [S, G, G, G, G]
    ];

    bytes memory terrain = convertTerrainArrayToBytes(map);

    createParcel(x_p, y_p, terrain);

    vm.stopBroadcast();
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