// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibArray } from "../libraries/LibArray.sol";
import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";


uint256 constant ID = uint256(keccak256("system.AssembleTeam"));

contract AssembleTeamSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256[] memory pokemonIDs) = abi.decode(args, (uint256[]));
    return executeTyped(pokemonIDs);
  }

  function executeTyped(uint256[] memory pokemonIDs) public returns (bytes memory) { 
    uint256 playerID = addressToEntity(msg.sender);
    
    // TODO: cannot assemble when in dungeon
    require(pokemonIDs.length == 4, "Assemble Team: team length is not 4");
    require(!LibBattle.isPlayerInBattle(components, playerID), "Player is in battle");
    uint256[] memory pokemonIDs_no_zero = LibArray.filterZeroOffArray(pokemonIDs);

    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    uint256[] memory team_pokemonIDs = LibTeam.teamIDToPokemonIDs(components, teamID);

    // for IDs that is in pokemonIDs but not in team_pokemonIDs, check its owner, must be playerID
    uint256[] memory new_to_team = LibArray.getRelativeComplement(pokemonIDs_no_zero, team_pokemonIDs);
    for (uint i=0; i<new_to_team.length; i++) {
      require(LibOwnedBy.isOwnedBy(components, new_to_team[i], playerID), "Assemble Team: not owned by player");
      LibOwnedBy.setOwner(components, new_to_team[i], teamID);
    }

    // for IDs that is in team_pokemonIDs but not in pokemonIDs, set its owner back to playerID
    uint256[] memory old_out_team = LibArray.getRelativeComplement(team_pokemonIDs, pokemonIDs_no_zero);
    for (uint i=0; i<old_out_team.length; i++) {
      LibOwnedBy.setOwner(components, old_out_team[i], playerID);
    }

    // set pokemonIDs to teamPokemons
    LibTeam.setTeamPokemons(components, pokemonIDs, teamID);
  }

}