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

contract BattleTest is PokemonTest {

  constructor() PokemonTest(new Deploy()) { }

  function testMultiplePvEBattles() public {
    setup();
    spawnPlayer(4, alice);
    uint256 aliceID = addressToEntity(alice);
    // addOneToTeam(aliceID, alice, 2, 7, 2, Coord);
    crawlTo(Coord(0,1), alice);

    // vm.expectRevert("cannot move during a battle");
    crawlTo(Coord(0,2), alice);
    crawlTo(Coord(0,3), alice);
    
    uint256 battleID =  LibBattle.playerIDToBattleID(components, aliceID);
    autoPvEBattle(battleID, alice);

    // crawlTo(Coord(0,2), alice);
    // battleID =  LibBattle.playerIDToBattleID(components, aliceID);
    // autoPvEBattle(battleID, alice);

    // crawlTo(Coord(0,3), alice);
    // battleID =  LibBattle.playerIDToBattleID(components, aliceID);
    // autoPvEBattle(battleID, alice);

    // crawlTo(Coord(0,4), alice);
    // battleID =  LibBattle.playerIDToBattleID(components, aliceID);
    // autoPvEBattle(battleID, alice);


  }



  // function testPvEBattleTimeElapse() public {
  //   setup();
  //   uint256 aliceID = addressToEntity(alice);
  //   uint256 bobID = addressToEntity(bob);
  //   crawlTo(Coord(0,1), alice);
  //   crawlTo(Coord(1,1), bob);
  //   uint256 bob_pokemonID = LibTeam.playerIDToTeamPokemonIDs(components, bobID)[0];
    
  //   uint256 battleID =  LibBattle.playerIDToBattleID(components, aliceID);
  //   uint256[] memory alicePokemonIDs;
  //   uint256 targetID;
  //   uint32 target_pre_hp;
  //   uint32 target_pos_hp;
  //   uint counter;

  //   while(LibBattle.isBattleOrderExist(components, battleID)) {
  //     // get next pokemon's ID
  //     uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
  //     console.log("next pokemon: ", nextPokemon);
  //     // get player's pokemons in the team
  //     alicePokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);
      
  //     // see which pokemon go next
  //     if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs) && (counter & 1) == 0) {
  //       // select a target
  //       targetID = LibBattle.playerIDToEnemyPokemons(components, aliceID)[0];
  //       // TEST 1: bob cannot commit before time passes
  //       vm.expectRevert("Battle: not your battle");
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
  //       console.log("bob cannot commit before time pass");

  //       // alice commits attack before time pass
  //       executeBattle(battleID, targetID, BattleActionType.Move0, alice); 
  //       console.log("alice can commit attack before time pass");

  //       vm.expectRevert("Battle: not your battle");
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
  //       console.log("bob cannot call battleID before max_duration pass");

  //       // TEST 2: bob can reveal after max_duration is passed
  //       target_pre_hp = LibPokemon.getHP(components, targetID);
  //       vm.warp(block.timestamp + MAX_DURATION);
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
  //       console.log("bob can call after max_duration pass");
    
  //       assertTrue(nextPokemon != LibBattle.getBattleNextOrder(components, battleID));
  //       target_pos_hp = LibPokemon.getHP(components, targetID);
  //       assertTrue(target_pre_hp == target_pos_hp);
  //       console.log("---------- bob skips alice's commit to next after max duration pass -----------");

  //       counter++;
  //     } else if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs) && (counter & 1) != 0) {
  //       targetID = LibBattle.playerIDToEnemyPokemons(components, aliceID)[0];
  //       target_pre_hp = LibPokemon.getHP(components, targetID);
  //       // TEST 3: bob can commit after time passes
  //       vm.warp(block.timestamp + MAX_DURATION);
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
        
  //       assertTrue(nextPokemon != LibBattle.getBattleNextOrder(components, battleID));
  //       target_pos_hp = LibPokemon.getHP(components, targetID);
  //       assertTrue(target_pre_hp == target_pos_hp);
  //       console.log("---------- bob skips alice's battle (no precommit) to next after max duration pass -----------");

  //       counter++;
  //     }
      
  //     else {
  //       targetID = LibBattle.playerIDToEnemyPokemons(components, BattleSystemID)[0];
  //       // TEST 4: anyone can commit on behalf of bot
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
  //       // TEST 5: no one can reveal on behalf of bot when wait block not passes
  //       vm.expectRevert("Battle: bot has not passed wait block");
  //       executeBattle(battleID, targetID, BattleActionType.Move0, bob); 
  //       vm.expectRevert("Battle: bot has not passed wait block");
  //       executeBattle(battleID, targetID, BattleActionType.Move0, alice); 
  //       console.log("no one can commit for bot when wait block not passes");

  //       // TEST 6: anyone can reveal on behalf of bot after wait block
  //       target_pre_hp = LibPokemon.getHP(components, targetID);
  //       vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
  //       executeBattle(battleID, targetID, BattleActionType.Skip, bob); 
  //       target_pos_hp = LibPokemon.getHP(components, targetID);
  //       assertTrue(target_pre_hp > target_pos_hp);
  //       console.log("---------- bob reveals bot's attack to drop alice's pokemon from", target_pre_hp, " to ", target_pos_hp);
  //     }
      
  //   }
  //   // TEST: respawning alice after defeated
  //   assertTrue(!LibBattle.isPlayerInBattle(components, aliceID));
  //   assertTrue(!LibBattle.isBattleIDExist(components, aliceID));
  //   assertTrue(LibTeam.playerIDToTeamPokemonIDs(components, aliceID).length ==0);
  //   console.log("Alice no longer in battle with zero pokemon in team");
  //   assertTrue(!LibMap.hasPosition(components, aliceID));
  //   console.log("Alice no longer on the map");
  //   spawnPlayer(1, alice);
  //   assertTrue(LibTeam.playerIDToTeamPokemonIDs(components, aliceID).length ==0);
  //   console.log("Alice respawned with zero pokemon in team");

  // }

  // function testPvEBattleUntilDefeat() public { 
  //   setup();

  //   uint256 aliceID = addressToEntity(alice);
  //   uint256 alice_teamID = LibTeam.playerIDToTeamID(components, aliceID);
  //   console.log("alice_team:", alice_teamID);

  //   addOneToTeam(aliceID, alice, 2, 7, 2);

  //   crawlTo(Coord(0,1), alice);
  //   uint256 battleID =  LibBattle.playerIDToBattleID(components, aliceID);
  //   uint256[] memory alicePokemonIDs;
  //   uint32 target_pre_hp;
  //   uint32 target_pos_hp;
    
  //   while(LibBattle.isBattleOrderExist(components, battleID)) {
  //     uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
  //     console.log("next pokemon", nextPokemon);
  //     alicePokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);
  //     if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs)) {
  //       uint256 targetID = LibBattle.playerIDToEnemyPokemons(components, aliceID)[0];
  //       console.log("targetID", targetID);
  //       target_pre_hp = LibPokemon.getHP(components, targetID);
  //       executeBattle(battleID, targetID, BattleActionType.Move0, alice);
  //       vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
  //       executeBattle(battleID, targetID, BattleActionType.Move0, alice);
  //       target_pos_hp = LibPokemon.getHP(components, targetID);
  //       console.log("targetID's HP drops from ", target_pre_hp, " to ", target_pos_hp);
  //     } else {
        
  //       uint256 targetID = LibBattle.playerIDToEnemyPokemons(components, BattleSystemID)[0];
  //       target_pre_hp = LibPokemon.getHP(components, targetID);
  //       executeBattle(battleID, 0, BattleActionType.Move0, alice);
  //       vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
  //       executeBattle(battleID, 0, BattleActionType.Move0, alice);
  //       target_pos_hp = LibPokemon.getHP(components, alicePokemonIDs[0]);
  //       console.log("alice pokemon 1 HP drops from ", target_pre_hp, " to ", target_pos_hp);
  //     }

  //   }
  //   assertTrue(!LibBattle.isPlayerInBattle(components, aliceID));
  //   assertTrue(!LibBattle.isBattleIDExist(components, aliceID));

  // }

  // function testPvEBattleUntilCapture() public { }


  function addOneToTeam(uint256 playerID, address player, uint32 index, uint32 level, uint slot_num, Coord memory coord) internal {
    uint256 pokemonID = exectueGiftPokemon(index, level, playerID);
    uint256 teamID = LibTeam.playerIDToTeamID(components, playerID);
    console.log("test3", pokemonID);
    uint256[] memory teamPokemons = LibTeam.teamIDToPokemons(components, teamID);
    teamPokemons[slot_num] = pokemonID;
    executeAssembleTeam(teamPokemons, coord, player);

  }

}