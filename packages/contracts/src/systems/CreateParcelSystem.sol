// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { TerrainType } from "../TerrainType.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ObstructionComponent, ID as ObstructionComponentID } from "../components/ObstructionComponent.sol";
import { EncounterTriggerComponent, ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";

import { ParcelCoordComponent, ID as ParcelCoordComponentID} from "../components/ParcelCoordComponent.sol";
import { ParcelComponent, ID as ParcelComponentID, Parcel, parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";

import { LibMap } from "../libraries/LibMap.sol";

uint256 constant ID = uint256(keccak256("system.CreateParcel"));

// need to set in PositionComponent, EncounterableComponent, MovableComponent
// ParcelComponent, ParcelPokemonComponent
contract CreateParcelSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (int32 x_p, int32 y_p, bytes memory terrainMap) = abi.decode(
      args, (int32, int32, bytes));
    return executeTyped(x_p, y_p, terrainMap);
  }

  function executeTyped(int32 x_p, int32 y_p, bytes memory terrainMap) public returns (bytes memory) {
    // TODO: need to write some authorization here

    uint256 parcelID = world.getUniqueEntityId();
    ParcelComponent pComp = ParcelComponent(getAddressById(components, ParcelComponentID));
    pComp.set(parcelID, Parcel(x_p, y_p, terrainMap));

    ParcelCoordComponent pcComp = ParcelCoordComponent(getAddressById(components, ParcelCoordComponentID));
    pcComp.set(parcelID, Coord(x_p, y_p));

    int32 xOffset = int32(parcelWidth) * x_p;
    int32 yOffset = int32(parcelHeight) * y_p;
    
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        int32 x = int32(i) + xOffset;
        int32 y = int32(j) + yOffset;
        // convert byte to enum
        TerrainType terrainType = TerrainType(uint8(terrainMap[(j * parcelWidth) + i]));

        // normal terrain
        if (terrainType == TerrainType.Path || 
            terrainType == TerrainType.Gravel ||
            terrainType == TerrainType.Grass ||
            terrainType == TerrainType.Flower) continue;
        
        uint256 positionID = world.getUniqueEntityId();
        LibMap.setPosition(components, positionID, Coord(x, y));

        // encounter  
        if (terrainType == TerrainType.GrassTall) {
          LibMap.setEncounterTrigger(components, positionID);
          continue;
        }

        // normal obstruction
        if (terrainType == TerrainType.Boulder ||
            terrainType == TerrainType.TreeShort ||
            terrainType == TerrainType.TreeTall
        ) {
          LibMap.setObstruction(components, positionID);
          continue;
        } 
        
        // special obstruction - nurse
        if (terrainType == TerrainType.Nurse) {
          LibMap.setObstruction(components, positionID);
          LibMap.setNurse(components, positionID);
          continue;
        }

        // special obstruction - PC
        if (terrainType == TerrainType.PC) {
          LibMap.setObstruction(components, positionID);
          LibMap.setPC(components, positionID);
          continue;
        }

        // special obstruction - Spawn
        if (terrainType == TerrainType.Spawn) {
          LibMap.setObstruction(components, positionID);
          LibMap.setSpawn(components, positionID);
          continue;
        }

        // level check
        if (LibMap.isLevelCheck(terrainType)) {
          uint32 level = LibMap.levelCheckEnumToUint32(terrainType);
          LibMap.setLevelCheck(components, positionID, level);
        }

      }
    }

  }
}