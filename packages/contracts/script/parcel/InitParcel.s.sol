pragma solidity ^0.8.13;

import "../../lib/forge-std/src/Script.sol";
import { Parcel } from "../../src/components/ParcelComponent.sol";
import { TerrainType } from "../../src/TerrainType.sol";


// source .env
// forge script script/parcel/InitParcel.s.sol:InitParcelScript --rpc-url http://localhost:8545 --broadcast

contract InitParcelScript is Script {

  address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
  address InitParcelSystem = 0x4826533B4897376654Bb4d4AD88B7faFD0C98528;
  int32 x_p = 0;
  int32 y_p = 0;
  uint256 parcelID = 2481041784956016742021570618494952475758789857281704946240779902470294861374;
  
  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    IInitParcelSystem(InitParcelSystem).executeTyped(parcelID);

    vm.stopBroadcast();
  }
}

interface IInitParcelSystem {
  function executeTyped(uint256 parcelID) external returns (bytes memory);
}

interface IWorld {
  function getUniqueEntityId() external view returns (uint256);
}

