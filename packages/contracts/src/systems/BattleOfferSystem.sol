// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { Coord } from "../components/PositionComponent.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibMap } from "../libraries/LibMap.sol";

import { LibBattle } from "../libraries/LibBattle.sol";

uint256 constant ID = uint256(keccak256("system.BattleOffer"));

contract BattleOfferSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 offereeID) = abi.decode(args, (uint256));
    return executeTyped(offereeID);
  }

  function executeTyped(uint256 offereeID) public returns (bytes memory) { 
    uint256 offerorID = addressToEntity(msg.sender);

    Coord memory offeror_coord = LibMap.getPosition(components, offerorID);
    Coord memory offeree_coord = LibMap.getPosition(components, offereeID);
    require(LibMap.distance(offeror_coord, offeree_coord) == 1, "can not battle with not adjacent player");
    
    require(LibMap.isPositionDungeon(world, components, offeror_coord), "offeror is not in dungeon");
    require(LibMap.isPositionDungeon(world, components, offeree_coord), "offeree is not in dungeon");

    require(!LibBattle.offerorHasOffer(components, offerorID), "offeror has made offer!");
    require(!LibBattle.offerorHasOffer(components, offereeID), "offeree has made offer!");

    require(!LibBattle.offereeHasOffer(components, offerorID), "offeror has existing offer!");
    require(!LibBattle.offereeHasOffer(components, offereeID), "offeree has existing offer!");

    require(!LibBattle.isPlayerInBattle(components, offerorID), "offeror is in battle!");
    require(!LibBattle.isPlayerInBattle(components, offereeID), "offeree is in battle!");

    LibBattle.makeOffer(components, offerorID, offereeID);
  }

}