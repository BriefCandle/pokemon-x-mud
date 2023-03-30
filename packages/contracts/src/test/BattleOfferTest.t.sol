// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Deploy } from "./Deploy.sol";
import { PokemonTest } from "./PokemonTest.t.sol"; 
import "std-contracts/test/MudTest.t.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { Coord } from "../components/PositionComponent.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { MAX_DURATION } from "../components/BattleActionTimestampComponent.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol"; 
import { LibArray } from "../libraries/LibArray.sol"; 
import { LibAction } from "../libraries/LibAction.sol"; 
import { LibMove } from "../libraries/LibMove.sol"; 
import { LibMap } from "../libraries/LibMap.sol"; 

contract CrawlTest is PokemonTest {

  constructor() PokemonTest(new Deploy()) { }

  function testBattleOffer() public {
    setup();
    spawnPlayer(1, alice);
    uint256 aliceID = addressToEntity(alice);
    spawnPlayer(1, bob);
    uint256 bobID = addressToEntity(bob);
    spawnPlayer(1, eve);
    uint256 eveID = addressToEntity(eve);
    
    vm.expectRevert("can not battle with not adjacent player");
    executeBattleOffer(eveID, alice);

    executeBattleOffer(bobID, alice);

    // executeBattleDecline(bobID, bob);

    executeBattleAccept(bob);
    

  }

  function autoPvPBattle(uint256 battleID, address player1, address player2) internal { 
    uint256 player1_ID = addressToEntity(player1);
    uint256 player2_ID = addressToEntity(player2);

    uint256 nextPokemon;
    uint256[] memory player1_PokemonIDs;
    uint256[] memory player2_PokemonIDs;
    uint256 targetID;
    console.log("--------- PvP Battle Begins ---------");   
    while(LibBattle.isBattleOrderExist(components, battleID)) {
      nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
      player1_PokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, player1_ID);
      player2_PokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, player2_ID);
      
      if (LibArray.isValueInArray(nextPokemon, player1_PokemonIDs)) {
        targetID = LibBattle.playerIDToEnemyPokemons(components, player1_ID)[0];
        executeBattle(battleID, targetID, BattleActionType.Move0, player1);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(battleID, targetID, BattleActionType.Move0, player1);
      } else {
        targetID = LibBattle.playerIDToEnemyPokemons(components, player2_ID)[0];
        executeBattle(battleID, targetID, BattleActionType.Move0, player2);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(battleID, targetID, BattleActionType.Move0, player2);
      }
    }
  }
}