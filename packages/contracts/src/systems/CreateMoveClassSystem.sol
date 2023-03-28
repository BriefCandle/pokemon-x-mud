// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { MoveNameComponent, ID as MoveNameComponentID } from "../components/MoveNameComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";
import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";

uint256 constant ID = uint256(keccak256("system.CreateMoveClass"));

// set MoveName, MoveInfo, and MoveEffect
contract CreateMoveClassSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (string memory name, MoveInfo memory info, MoveEffect memory effect) = abi.decode(
      args, (string, MoveInfo, MoveEffect));
    return executeTyped(name, info, effect);
  }

  function executeTyped(string memory name, MoveInfo memory info, MoveEffect memory effect) public returns (bytes memory) {
    // TODO: need to write some authorization here
    uint256 entityID = world.getUniqueEntityId();

    MoveNameComponent nameComp = MoveNameComponent(getAddressById(components, MoveNameComponentID));
    nameComp.set(entityID, name);

    MoveInfoComponent infoComp = MoveInfoComponent(getAddressById(components, MoveInfoComponentID));
    infoComp.set(entityID, info);

    MoveEffectComponent effectComp = MoveEffectComponent(getAddressById(components, MoveEffectComponentID));
    effectComp.set(entityID, effect);
  }
}