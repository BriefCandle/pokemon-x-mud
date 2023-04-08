pragma solidity ^0.8.13;

import { PokemonScript } from "./PokemonScript.s.sol";
import { CreateDungeonSystem, ID as CreateDungeonSystemID } from "../src/systems/CreateDungeonSystem.sol";
import { ID as PositionComponentID, Coord } from "../src/components/PositionComponent.sol";
import { LibMap } from "../src/libraries/LibMap.sol";

// forge script script/CreateDungeon.s.sol:CreateDungeonScript --rpc-url http://localhost:8545 --broadcast

contract CreateDungeonScript is PokemonScript {

  Coord parcel_coord = Coord(1,1);
  uint32 level = 5;
  uint32[] indexes = [1];

  function run() public { 
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    uint256 parcelID = LibMap.getParcelID(world, parcel_coord)[0];
    CreateDungeonSystem(system(CreateDungeonSystemID)).executeTyped(parcelID, level, indexes);

    vm.stopBroadcast();
  }

}