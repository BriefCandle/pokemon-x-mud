// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { Coord } from "../components/PositionComponent.sol";

import { LibTeam } from "../libraries/LibTeam.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";



uint256 constant ID = uint256(keccak256("system.RestoreTeamHP"));

contract RestoreTeamHPSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (Coord memory coord) = abi.decode(args, (Coord));
    return executeTyped(coord);
  }

  function executeTyped(Coord memory coord) public returns (bytes memory) { 
    uint256 playerID = addressToEntity(msg.sender);
    
    // require Nurse is adjacent to player at coord
    require(LibMap.distance(LibMap.getPosition(components, playerID), coord) == 1, "nurse not in adjacent space");
    require(LibMap.nurses(world, coord).length > 0, "nurse not in coord");

    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);

    uint256[] memory pokemonIDs = LibTeam.teamIDToPokemonIDs(components, teamID);
    for (uint i; i<pokemonIDs.length; i++) {
      uint16 max_HP = LibPokemon.getPokemonIDMaxHP(components, pokemonIDs[i]);
      LibPokemon.setHP(components, pokemonIDs[i], max_HP);
    }

  }

}