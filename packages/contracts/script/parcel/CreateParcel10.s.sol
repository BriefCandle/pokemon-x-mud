pragma solidity ^0.8.13;

import { CreateParcelScript } from "./CreateParcel.s.sol";
import { Parcel, parcelWidth, parcelHeight } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/CreateParcel10.s.sol:CreateParcel10Script --rpc-url http://localhost:8545 --broadcast

contract CreateParcel10Script is CreateParcelScript {
  
  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    x_p = 1;
    y_p = 0;

    map = [
      [S, S, S, S, S],
      [L, L, G, W, W],
      [L, L, G, G, G],
      [L, L, G, G, G],
      [G, G, G, G, G]
    ];

    bytes memory terrain = convertTerrainArrayToBytes(map);

    createParcel(x_p, y_p, terrain);

    vm.stopBroadcast();
  }
}
