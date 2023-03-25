// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";

uint256 constant ID = uint256(keccak256("system.HandlePokemonDead"));

contract HandlePokemonDeadSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 attackerID, uint256 targetID) = abi.decode(
      args, (uint256, uint256));
    return executeTyped(attackerID, targetID);
  }

  function executeTyped(uint256 attackerID, uint256 targetID) public returns (bytes memory) {
    
    require(LibPokemon.isPokemonDead(components, targetID), "HandlePokemonDead: not dead");
    
    uint256 teamID = LibTeam.pokemonIDToTeamID(components, targetID);
    LibTeam.removePokemonFromTeamPokemons(components, targetID, teamID);

    OwnedByComponent(getAddressById(components, OwnedByComponentID)).set(
      targetID, addressToEntity(address(0))
    );

    uint256 battleID = LibBattle.teamIDToBattleID(components, teamID);
    LibBattle.removePokemonFromBattleOrder(components, targetID, battleID);

    uint32 exp_award = LibPokemon.getExpAward(components, targetID);
    (uint32 levelNew, uint32 expNew) = LibPokemon.getNewLevelAndExp(components, attackerID, exp_award);
    LibPokemon.setExp(components, attackerID, expNew);
    LibPokemon.setLevel(components, attackerID, levelNew);
  }

}
