// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibMap } from "../libraries/LibMap.sol";


import { ID as BattleSystemID } from "./BattleSystem.sol";

uint256 constant ID = uint256(keccak256("system.HandleTeamDefeat"));

contract HandleTeamDefeatSystem is System {

  constructor(IWorld _world, address _components) System(_world, _components) { }

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 teamID) = abi.decode(args, (uint256));
    return executeTyped(teamID);
  }

  function executeTyped(uint256 teamID) public returns (bytes memory) {
    require(LibTeam.isTeamDefeat(components, teamID), "HandleTeamDefeat: team not defeated");
    
    uint256 battleID = LibBattle.teamIDToBattleID(components, teamID);
    // uint256 winner_teamID = LibBattle.teamIDToEnemyTeamID(components, teamID);

    // 1) remove BattlePokemons
    LibBattle.removeBattleOrder(components, battleID);

    // 2) remove all teams from BattleTeam
    LibBattle.removeAllBattleTeams(components, battleID);

    // 3) remove BattleActionTimestamp
    LibBattle.removeBattleActionTimestamp(components, battleID);

    // 4) remove defeat team if it is a bot
    uint256 playerID = LibTeam.teamIDToPlayerID(components, teamID);
    if (playerID == BattleSystemID) {
      LibTeam.removeTeam(components, teamID);
    } 
    
    // TODO: handle player respawn & penalties(?) for losing

    // 5) remove player's position
    if (LibMap.hasPosition(components,playerID)) {
      LibMap.removePosition(components, playerID);
    }


  }

}
