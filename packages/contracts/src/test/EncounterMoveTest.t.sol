// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Deploy } from "./Deploy.sol";
import { PokemonTest } from "./PokemonTest.t.sol"; 
import "std-contracts/test/MudTest.t.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol"; 
import { LibArray } from "../libraries/LibArray.sol"; 
import { LibAction } from "../libraries/LibAction.sol"; 
import { LibMove } from "../libraries/LibMove.sol"; 


import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { BattleType } from "../BattleType.sol";


import { CrawlSystem, ID as CrawlSystemID } from "../systems/CrawlSystem.sol";
import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";

import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { TeamBattleComponent, ID as TeamBattleComponentID } from "../components/TeamBattleComponent.sol";


contract EncounterMoveTest is PokemonTest {

  uint256 nounce = 0;

  BattleSystem battleSystem;

  constructor() PokemonTest(new Deploy()) { }

  function testEncounterAttackRNG() public {
    setup();
    crawlTo(Coord(0,1));
    setupBattle();

    uint256 aliceID = addressToEntity(alice);
    uint256[] memory alicePokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID);
    uint256 battleID =  LibBattle.playerIDToBattleID(components, BattleSystemID);
    uint256[] memory enemyPokemonIDs = LibBattle.playerIDToEnemyPokemons(components, aliceID);
    uint256 targetID;

    uint256 target_pre_hp;
    uint256 target_pos_hp;

    BattleActionType action = BattleActionType.Move0;
    uint8 moveNumber = LibAction.actionToMoveNumber(action);
    uint counter;

    while (counter<4) {
      uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);

      if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs)) {
        targetID = enemyPokemonIDs[0];
        target_pre_hp = LibPokemon.getHP(components, targetID);
        uint256 moveID = LibPokemon.getMoves(components, nextPokemon)[moveNumber];

        uint32 DMG_default = LibMove.calculateMoveEffectOnHP(components, nextPokemon, targetID, moveID, 255);
        uint32 DMG_crit = LibMove.calculateMoveEffectOnHP(components, nextPokemon, targetID, moveID, 0);
        assertEq(DMG_default * 2, DMG_crit);
        
        if (counter % 2 == 0) {
          executeBattle(nextPokemon, targetID, action, alice);
          // gives 255 rng if not pass wait blocks
          executeBattle(nextPokemon, targetID, action, alice);
          target_pos_hp = LibPokemon.getHP(components, targetID);
          assertEq(DMG_default, target_pre_hp-target_pos_hp);
          console.log("alice attacks NOT crit for invalid reveal");
        } else {
          executeBattle(nextPokemon, targetID, action, alice);
          vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
          // Hard to test crit for player: need to cheat a number 
          // into pokemon's SPD to guarantee a crit
          
          // revert when not same action
          vm.expectRevert(LibRNG.LibRNG__notExistActionType.selector);
          executeBattle(nextPokemon, targetID, BattleActionType.Move1, alice);
          console.log("alice reveal wrong action");
          // revert when not same target
          // vm.expectRevert(LibRNG.LibRNG__notExistTargetID.selector);
          // executeBattle(nextPokemon, 0, action, alice);
          console.log("alice reveal wrong target");
          executeBattle(nextPokemon, targetID, action, alice);
        }
      }  else {
        assertTrue(LibArray.isValueInArray(nextPokemon, enemyPokemonIDs));

        targetID = alicePokemonIDs[0];
        target_pre_hp = LibPokemon.getHP(components, targetID);
        uint256 moveID = LibPokemon.getMoves(components, nextPokemon)[moveNumber];

        uint32 DMG_default = LibMove.calculateMoveEffectOnHP(components, nextPokemon, targetID, moveID, 255);
        uint32 DMG_crit = LibMove.calculateMoveEffectOnHP(components, nextPokemon, targetID, moveID, 0);
        assertEq(DMG_default * 2, DMG_crit);
        executeBattle(0, 0, action, alice);
        executeBattle(0, 0, action, alice);
        target_pos_hp = LibPokemon.getHP(components, targetID);
        assertEq(DMG_crit, target_pre_hp-target_pos_hp);
        console.log("enemy attacks a crit for invalid reveal");

      }        
      counter++;
    }
  }

  function testEncounterAttackForAuthorization() public {
    setup();
    crawlTo(Coord(0,1));
    setupBattle();

    uint256 aliceID = addressToEntity(alice);
    uint256[] memory alicePokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID);
    uint256 battleID =  LibBattle.playerIDToBattleID(components, BattleSystemID);
    uint256[] memory enemyPokemonIDs = LibBattle.playerIDToEnemyPokemons(components, aliceID);
    uint256 targetID;

    BattleActionType action = BattleActionType.Move0;
    uint counter;

    // since attacking pokemonID is not a necessary input, not going to 
    // test wrong pokemonIDs for alice
    while (counter<4) {
      uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);

      if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs)) {
        // TEST 1: is player's turn, but wrong player, two scenarios
        // 1.1) if bob's team has no battleID
        targetID = enemyPokemonIDs[0];
        vm.expectRevert(LibTeam.LibTeam__TeamIDNotExist.selector);
        executeBattle(nextPokemon, targetID, action, bob);
        // 1.2) if bob's team has, it would check pokemonNext for bob's battle
        // not test it

        // TEST 2: is player's turn, target pokemon not in enemy team
        targetID = alicePokemonIDs[1];
        vm.expectRevert(LibBattle.LibBattle__EnemyPokemonIDNotExist.selector);
        executeBattle(nextPokemon, targetID, action, alice);

        targetID = enemyPokemonIDs[0];
        executeBattle(nextPokemon, targetID, action, alice);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(nextPokemon, targetID, action, alice);
        console.log("alice's pokemon attacks");

      } else {
        assertTrue(LibArray.isValueInArray(nextPokemon, enemyPokemonIDs));
        // TEST 2: not player's turn, but bot's turn, only player can call
        vm.expectRevert(LibTeam.LibTeam__TeamIDNotExist.selector);
        executeBattle(nextPokemon, targetID, action, bob);

        executeBattle(0, 0, action, alice);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(0, 0, action, alice);
        console.log("enemy pokemon attacks");
      }
      counter++;
    }
    
  }

  function testEncounterAttackForDefeatTeam() public {
    setup();
    crawlTo(Coord(0,1));
    setupBattle();

    uint256 battleID =  LibBattle.playerIDToBattleID(components, BattleSystemID);
    bool isBattleExist = LibBattle.isBattleOrderExist(components, battleID);
    uint256 aliceID = addressToEntity(alice);
    uint256[] memory alicePokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID);
    
    uint256 targetID = LibBattle.playerIDToEnemyPokemons(components, aliceID)[0];
    uint32 target_pre_hp;
    uint32 target_pos_hp;
    while(isBattleExist) {
      uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
      if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs)) {
        target_pre_hp = LibPokemon.getHP(components, targetID);
        executeBattle(nextPokemon, targetID, BattleActionType.Move0, alice);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(nextPokemon, targetID, BattleActionType.Move0, alice);
        target_pos_hp = LibPokemon.getHP(components, targetID);
        console.log("targetID's HP drops from ", target_pre_hp, " to ", target_pos_hp);
      } else {
        target_pre_hp = LibPokemon.getHP(components, alicePokemonIDs[0]);
        executeBattle(0, 0, BattleActionType.Move0, alice);
        vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
        executeBattle(0, 0, BattleActionType.Move0, alice);
        target_pos_hp = LibPokemon.getHP(components, alicePokemonIDs[0]);
        console.log("alice pokemon 1 HP drops from ", target_pre_hp, " to ", target_pos_hp);
      }

      isBattleExist = LibBattle.isBattleOrderExist(components, battleID);
    }
    uint256 aliceTeam = LibTeam.playerIDToTeamID(components, aliceID);
    
    assertTrue(!TeamBattleComponent(getAddressById(components, TeamBattleComponentID)).has(aliceTeam));

  }



  function executeBattle(uint256 pokemonID, uint256 targetID, BattleActionType action, address player) prank(player) internal {
    battleSystem.executeTyped(pokemonID, targetID, action);
  }

  function crawlTo(Coord memory coord) prank(alice) internal {
    CrawlSystem crawlS = CrawlSystem(system(CrawlSystemID));
    crawlS.executeTyped(coord);
  }

  function setupBattle() internal {
    battleSystem = BattleSystem(system(BattleSystemID));
  }

  function logArray(uint[] memory array) internal view {
    for (uint i; i<array.length; i++) {
      console.log(array[i]);
    }
  }

  
}