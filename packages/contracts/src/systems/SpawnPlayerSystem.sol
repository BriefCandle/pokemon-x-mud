// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { ObtainFirstPokemonSystem, ID as ObtainFirstPokemonSystemID } from "./ObtainFirstPokemonSystem.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";

uint256 constant ID = uint256(keccak256("system.SpawnPlayer"));

// spawn a player to parcel(0,0)
contract SpawnPlayerSystem is System {
  

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 index) = abi.decode(args, (uint32));
    return executeTyped(index);
  }

  function executeTyped(uint32 index) public returns (bytes memory) {
    uint256 playerId = addressToEntity(msg.sender);

    PlayerComponent player = PlayerComponent(getAddressById(components, PlayerComponentID));
    if (!player.has(playerId)) {
      
      player.set(playerId);
      
      LibMap.spawnPlayerOnMap(world, components, playerId);
      
      ObtainFirstPokemonSystem(getAddressById(world.systems(), ObtainFirstPokemonSystemID)).executeTyped(
        index, playerId
      );

    } else { // TODO: consider moving it to RespawnPlayerSystem?
      
      if (!LibMap.hasPosition(components, playerId)) {
        
        LibMap.spawnPlayerOnMap(world, components, playerId);
      }
    }
  }



}