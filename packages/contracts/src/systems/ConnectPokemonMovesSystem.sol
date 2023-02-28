// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { MoveLevelPokemonComponent, ID as MoveLevelPokemonComponentID } from "../components/MoveLevelPokemonComponent.sol";

uint256 constant ID = uint256(keccak256("system.ConnectPokemonMoves"));

// set MoveLevel
contract ConnectPokemonMovesSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 pokemonID, uint256[] memory moves) = abi.decode(
      args, (uint256, uint256[]));
    return executeTyped(pokemonID, moves);
  }

  function executeTyped(uint256 pokemonID, uint256[] memory moves) public returns (bytes memory) {
    // need to write some authorization here
    // need to check if pokemon index exist
    require(moves.length <= 15, "Moves need to be 15 in length");
    MoveLevelPokemonComponent mlpComp = MoveLevelPokemonComponent(getAddressById(components, MoveLevelPokemonComponentID));
    mlpComp.set(pokemonID, moves);
  }
}