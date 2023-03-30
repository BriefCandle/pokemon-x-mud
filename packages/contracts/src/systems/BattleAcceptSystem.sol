// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { Coord } from "../components/PositionComponent.sol";
import { LibTeam } from "../libraries/LibTeam.sol";

import { LibBattle } from "../libraries/LibBattle.sol";

uint256 constant ID = uint256(keccak256("system.BattleAccept"));

contract BattleAcceptSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    uint256 offereeID = addressToEntity(msg.sender);

    require(LibBattle.offereeHasOffer(components, offereeID), "no existing offer");

    uint256 offerorID = LibBattle.offereeToOfferor(components, offereeID);
    
    LibBattle.acceptOffer(world, components, offerorID, offereeID);
  }

}