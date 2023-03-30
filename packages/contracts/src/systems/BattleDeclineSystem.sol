// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { Coord } from "../components/PositionComponent.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibMap } from "../libraries/LibMap.sol";

import { LibBattle } from "../libraries/LibBattle.sol";

uint256 constant ID = uint256(keccak256("system.BattleDecline"));

contract BattleDeclineSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 offereeID) = abi.decode(args, (uint256));
    return executeTyped(offereeID);
  }

  function executeTyped(uint256 offereeID) public returns (bytes memory) { 
    require(LibBattle.offereeHasOffer(components, offereeID), "offeree has no offer");

    uint256 offerorID = LibBattle.offereeToOfferor(components, offereeID);

    if (LibBattle.isOfferValid(components, offerorID)) {
      require(offereeID == addressToEntity(msg.sender), "offeree must be sender to decline");
      _declineOffer(offerorID, offereeID);
    } else {
      _declineOffer(offerorID, offereeID);
    }
    
  }

  function _declineOffer(uint256 offerorID, uint256 offereeID) private {
    LibBattle.deleteOffer(components, offerorID);

    LibMap.removePosition(components, offereeID);
  }

}