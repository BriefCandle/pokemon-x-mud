// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { ObtainFirstPokemonSystem, ID as ObtainFirstPokemonSystemID } from "./ObtainFirstPokemonSystem.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";

uint256 constant ID = uint256(keccak256("system.Respawn"));

// spawn a player to parcel(0,0)
contract RespawnSystem is System {
  

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);

    PlayerComponent player = PlayerComponent(getAddressById(components, PlayerComponentID));
    require(player.has(playerID), "playerID exist");
    require(!LibMap.hasPosition(components, playerID), "player still on map");

    // TODO: respawn position component
        
    LibMap.spawnPlayerOnMap(world, components, playerID);
    
  }




}