// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { EncounterTriggerComponent, ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ObstructionComponent, ID as ObstructionComponentID } from "../components/ObstructionComponent.sol";
import { LevelCheckComponent, ID as LevelCheckComponentID } from "../components/LevelCheckComponent.sol";
import { TerrainNurseComponent, ID as TerrainNurseComponentID } from "../components/TerrainNurseComponent.sol";
import { TerrainPCComponent, ID as TerrainPCComponentID } from "../components/TerrainPCComponent.sol";
import { TerrainSpawnComponent, ID as TerrainSpawnComponentID } from "../components/TerrainSpawnComponent.sol";

import { ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";
import { ParcelCoordComponent, ID as ParcelCoordComponentID } from "../components/ParcelCoordComponent.sol";
import { DungeonLevelComponent, ID as DungeonLevelComponentID } from "../components/DungeonLevelComponent.sol";
import { DungeonPokemonsComponent, ID as DungeonPokemonsComponentID } from "../components/DungeonPokemonsComponent.sol";

import {TerrainType} from "../TerrainType.sol";

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

  function levelChecks(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, LevelCheckComponentID, new bytes(0));
    return world.query(fragments);
  }

  function nurses(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, TerrainNurseComponentID, new bytes(0));
    return world.query(fragments);
  }

  function PCs(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, TerrainPCComponentID, new bytes(0));
    return world.query(fragments);
  }

  function spawns(IWorld world, Coord memory coord) internal view returns (uint256[] memory) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, PositionComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.Has, TerrainSpawnComponentID, new bytes(0));
    return world.query(fragments);
  }

  function setObstruction(IUint256Component components, uint256 entityID) internal {
    ObstructionComponent(getAddressById(components, ObstructionComponentID)).set(entityID);
  }

  function setEncounterTrigger(IUint256Component components, uint256 entityID) internal {
    EncounterTriggerComponent(getAddressById(components, EncounterTriggerComponentID)).set(entityID);
  }

  function setLevelCheck(IUint256Component components, uint256 entityID, uint32 level) internal {
    LevelCheckComponent(getAddressById(components, LevelCheckComponentID)).set(entityID, level);
  }

  function isLevelCheck(TerrainType terrainType) internal pure returns (bool) {
    return (terrainType == TerrainType.LevelCheck1 || terrainType == TerrainType.LevelCheck2 ||
    terrainType == TerrainType.LevelCheck3 || terrainType == TerrainType.LevelCheck4 ||
    terrainType == TerrainType.LevelCheck5) ? true : false;
  }

  function levelCheckEnumToUint32(TerrainType terrainType) internal pure returns (uint32) {
    if (terrainType == TerrainType.LevelCheck1) return 10;
    if (terrainType == TerrainType.LevelCheck2) return 20;
    if (terrainType == TerrainType.LevelCheck3) return 30;
    if (terrainType == TerrainType.LevelCheck4) return 40;
    if (terrainType == TerrainType.LevelCheck5) return 50;
    return 0;
  }

  function getLevelCheck(IUint256Component components, uint256 entityID) internal view returns (uint32) {
    return LevelCheckComponent(getAddressById(components, LevelCheckComponentID)).getValue(entityID);
  }

  function setNurse(IUint256Component components, uint256 entityID) internal {
    TerrainNurseComponent(getAddressById(components, TerrainNurseComponentID)).set(entityID);
  }

  function setPC(IUint256Component components, uint256 entityID) internal {
    TerrainPCComponent(getAddressById(components, TerrainPCComponentID)).set(entityID);
  }

  function setSpawn(IUint256Component components, uint256 entityID) internal {
    TerrainSpawnComponent(getAddressById(components, TerrainSpawnComponentID)).set(entityID);
  }



  




  function setPosition(IUint256Component components, uint256 entityID, Coord memory coord) internal {
    PositionComponent(getAddressById(components, PositionComponentID)).set(entityID, coord);
  }

  function getPosition(IUint256Component components, uint256 entityID) internal view returns(Coord memory) {
    return PositionComponent(getAddressById(components, PositionComponentID)).getValue(entityID);
  }

  function hasPosition(IUint256Component components, uint256 entityID) internal view returns(bool) {
    return PositionComponent(getAddressById(components, PositionComponentID)).has(entityID);
  }

  function removePosition(IUint256Component components, uint256 entityID) internal {
    PositionComponent(getAddressById(components, PositionComponentID)).remove(entityID);
  }

  function positionCoordToParcelCoord(Coord memory position) internal pure returns (Coord memory parcel) {
    parcel = Coord(position.x / int32(parcelWidth), position.y / int32(parcelHeight));
  }

  // like getEntitiesWithValue()
  function getParcelID(IWorld world, Coord memory parcel_coord) internal view returns (uint256[] memory) {
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

  function isParcelDungeon(IUint256Component components, uint256 parcelID) internal view returns (bool) {
    return DungeonLevelComponent(getAddressById(components, DungeonLevelComponentID)).has(parcelID);
  }

  function isPositionDungeon(IWorld world, IUint256Component components, Coord memory position_coord) internal view returns (bool) {
    Coord memory parcel_coord = positionCoordToParcelCoord(position_coord);
    uint256 parcelID = getParcelID(world, parcel_coord)[0];
    return isParcelDungeon(components, parcelID);
  }

  /** ------------ setter for Dungeon level, pokemons ------------ */

  function setDungeonLevel(IUint256Component components, uint256 parcelID, uint32 level) internal  {
    DungeonLevelComponent(getAddressById(components, DungeonLevelComponentID)).set(parcelID, level);
  }

  function setDungeonPokemons(IUint256Component components, uint256 parcelID, uint32[] memory indexes) internal  {
    DungeonPokemonsComponent(getAddressById(components, DungeonPokemonsComponentID)).set(parcelID, indexes);
  }


  // query parcel (0,0)'s 25 terrain to find empty spot to spawn
  // no obstruction && no other players
  function spawnPlayerOnMap(IWorld world, IUint256Component components, uint256 playerId) internal {
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        Coord memory coord = Coord(int32(i), int32(j));
        if (obstructions(world, coord).length == 0 &&
        players(world, coord).length == 0) {
          setPosition(components, playerId, coord);
          return;
        }
      }
    }
    revert("No place to spawn");
  }

}