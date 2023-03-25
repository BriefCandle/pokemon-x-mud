// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";
import { ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ID as ObstructionComponentID } from "../components/ObstructionComponent.sol";
import { ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";
import { ParcelCoordComponent, ID as ParcelCoordComponentID } from "../components/ParcelCoordComponent.sol";
import { DungeonLevelComponent, ID as DungeonLevelComponentID } from "../components/DungeonLevelComponent.sol";
import { DungeonPokemonsComponent, ID as DungeonPokemonsComponentID } from "../components/DungeonPokemonsComponent.sol";


library LibMap {
  function distance(Coord memory from, Coord memory to) internal pure returns (int32) {
    int32 deltaX = from.x > to.x ? from.x - to.x : to.x - from.x;
    int32 deltaY = from.y > to.y ? from.y - to.y : to.y - from.y;
    return deltaX + deltaY;
  }

  function obstructions(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, ObstructionComponentID, new bytes(0));
    return world.query(fragments);
  }

  function encounterTriggers(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, EncounterTriggerComponentID, new bytes(0));
    return world.query(fragments);
  }

  function players(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, PlayerComponentID, new bytes(0));
    return world.query(fragments);
  }



  function positionCoordToParcelCoord(Coord memory position) internal pure returns (Coord memory parcel) {
    parcel = Coord(position.x / int32(parcelWidth), position.y / int32(parcelHeight));
  }

  // like getEntitiesWithValue()
  function parcelID(IWorld world, Coord memory parcel_coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](1);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, ParcelCoordComponentID, abi.encode(parcel_coord));
    return world.query(fragments);
  }

  // function dungeonParcelID(IWorld world, Coord memory parcel_coord) internal view returns (uint256[] memory) {
  //   WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
  //   fragments[0] = WorldQueryFragment(QueryType.HasValue, ParcelCoordComponentID, abi.encode(parcel_coord));
  //   fragments[0] = WorldQueryFragment(QueryType.Has, DungeonLevelComponentID, new bytes(0));
  //   return world.query(fragments);
  // }



  function isParcelExist(IUint256Component components, uint256 parcelID) internal view returns (bool) {
    return ParcelCoordComponent(getAddressById(components, ParcelCoordComponentID)).has(parcelID) ? true: false;
  }

  /** ------------ getter for Dungeon level, pokemons ------------ */

  function getDungeonLevel(IUint256Component components, uint256 parcelID) internal view returns (uint32) {
    return DungeonLevelComponent(getAddressById(components, DungeonLevelComponentID)).getValue(parcelID);
  }

  function getDungeonPokemons(IUint256Component components, uint256 parcelID) internal view returns (uint32[] memory) {
    return DungeonPokemonsComponent(getAddressById(components, DungeonPokemonsComponentID)).getValue(parcelID);
  }

  /** ------------ setter for Dungeon level, pokemons ------------ */

  function setDungeonLevel(IUint256Component components, uint256 parcelID, uint32 level) internal  {
    DungeonLevelComponent(getAddressById(components, DungeonLevelComponentID)).set(parcelID, level);
  }

  function setDungeonPokemons(IUint256Component components, uint256 parcelID, uint32[] memory indexes) internal  {
    DungeonPokemonsComponent(getAddressById(components, DungeonPokemonsComponentID)).set(parcelID, indexes);
  }
}