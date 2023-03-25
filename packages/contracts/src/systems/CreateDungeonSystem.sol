// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibMap } from "../libraries/LibMap.sol";

uint256 constant ID = uint256(keccak256("system.CreateDungeon"));

// set MoveName, MoveInfo, and MoveEffect
contract CreateDungeonSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 parcelID, uint32 level, uint32[] memory indexes) = abi.decode(
      args, (uint256, uint32, uint32[]));
    return executeTyped(parcelID, level, indexes);
  }

  function executeTyped(uint256 parcelID, uint32 level, uint32[] memory indexes) public returns (bytes memory) {
    // TODO: write some authorization here
    
    // 1) check parcelID exist
    require(LibMap.isParcelExist(components, parcelID), "Parcel not exist");

    // 2) set dungeon level
    LibMap.setDungeonLevel(components, parcelID, level);

    // 3) set dungeon pokemons
    LibMap.setDungeonPokemons(components, parcelID, indexes);

  }
}