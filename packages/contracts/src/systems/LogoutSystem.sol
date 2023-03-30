// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { LibMap } from "../libraries/LibMap.sol";

uint256 constant ID = uint256(keccak256("system.Logout"));

// spawn to parcel(0,0), 
contract LogoutSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) {
  }

  function execute(bytes memory args) public returns (bytes memory) {
    uint256 playerID = addressToEntity(msg.sender);
    LibMap.removePosition(components, playerID);
    
  }

  // function executeTyped(uint256 playerId) public returns (bytes memory) {

  //   PositionComponent position = PositionComponent(getAddressById(components, PositionComponentID));
  //   position.remove(playerId);
  // }

}