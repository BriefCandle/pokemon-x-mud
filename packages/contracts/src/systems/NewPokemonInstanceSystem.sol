// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";

uint256 constant ID = uint256(keccak256("system.NewPokemonInstance"));

// set 
contract NewPokemonInstanceSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (PokemonInstance memory instance) = abi.decode(
      args, (PokemonInstance));
    return executeTyped(instance);
  }

  function executeTyped(PokemonInstance memory instance) public returns (bytes memory) {
    // need to write some authorization here, only some system may call

    // require instance.classID exists

    uint256 entityID = world.getUniqueEntityId();

    PokemonInstanceComponent piComp = PokemonInstanceComponent(getAddressById(components, PokemonInstanceComponentID));
    piComp.set(entityID, instance);
  }
}