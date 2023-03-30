// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibArray } from "../libraries/LibArray.sol";
import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";


uint256 constant ID = uint256(keccak256("system.AssembleOldTeam"));

contract AssembleOldTeamSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256[] memory pokemonIDs) = abi.decode(args, (uint256[]));
    return executeTyped(pokemonIDs);
  }

  function executeTyped(uint256[] memory pokemonIDs) public returns (bytes memory) { 
    uint256 playerID = addressToEntity(msg.sender);
    
    require(pokemonIDs.length == 4, "Assemble Team: team length is not 4");
    require(!LibBattle.isPlayerInBattle(components, playerID), "Player is in battle");
    uint256[] memory pokemonIDs_no_zero = LibArray.filterZeroOffArray(pokemonIDs);

    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    uint256[] memory team_pokemonIDs = LibTeam.teamIDToPokemonIDs(components, teamID);

    require(LibArray.compareArrays(pokemonIDs_no_zero, team_pokemonIDs), "Assemble old team: not the same");

    // set pokemonIDs to teamPokemons
    LibTeam.setTeamPokemons(components, pokemonIDs, teamID);
  }

}