// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibArray } from "../libraries/LibArray.sol";
import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";


uint256 constant ID = uint256(keccak256("system.GiftPokemon"));

// admin test system, only available to admin, and for testing purposes
contract GiftPokemonSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 index, uint32 level, uint256 playerID) = abi.decode(args, (uint32, uint32, uint256));
    return executeTyped(index, level, playerID);
  }

  function executeTyped(uint32 index, uint32 level, uint256 playerID) public returns (bytes memory) { 
    // TODO: figure out how to ...
    // require(msg.sender ==  deployer, "shall be called by deployer");

    uint256 pokemonID = world.getUniqueEntityId();
    LibPokemon.spawnPokemon(components, pokemonID, index, level);

    LibOwnedBy.setOwner(components, pokemonID, playerID);

    return abi.encode(pokemonID);

  }

}