pragma solidity ^0.8.13;

import { CreateParcelScript } from "./CreateParcel.s.sol";
import { Parcel, parcelWidth, parcelHeight } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/CreateParcel01.s.sol:CreateParcel01Script --rpc-url http://localhost:8545 --broadcast

contract CreateParcel01Script is CreateParcelScript {
  
  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    x_p = 0;
    y_p = 1;

    map = [
      [S, G, G, G, LC],
      [S, G, G, G, LC],
      [S, G, G, G, LC],
      [S, G, G, G, LC],
      [S, G, G, G, LC]
    ];

    bytes memory terrain = convertTerrainArrayToBytes(map);

    createParcel(x_p, y_p, terrain);

    vm.stopBroadcast();
  }
}
