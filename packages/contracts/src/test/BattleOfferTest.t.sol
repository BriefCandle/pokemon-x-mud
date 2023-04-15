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
import { OFFER_DURATION } from "../components/BattleOfferTimestampComponent.sol";

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

  uint256 aliceID;
  uint256 bobID;
  uint256 eveID;

  constructor() PokemonTest(new Deploy()) { }

  function testBattleOffer() public {
    battleOfferSetup();
    
    vm.expectRevert("can not battle with not adjacent player");
    executeBattleOffer(eveID, alice);

    executeBattleOffer(bobID, alice);

    // TEST: offeror and offeror cannot move after offer is made
    vm.expectRevert("offeror cannot move");
    crawlTo(Coord(0,1), alice);
    vm.expectRevert("offeree cannot move");
    crawlTo(Coord(1,1), bob);

    // TEST: a third party cannot make an offer to offeree when an offer is made
    vm.expectRevert("offeree has existing offer!");
    executeBattleOffer(bobID, eve);
  }

  function testBattleDecline() public {
    battleOfferSetup();

    executeBattleOffer(bobID, alice);

    // TEST: when time not elpase, only offeree may decline offer
    vm.expectRevert("offeree must be sender to decline");
    executeBattleDecline(bobID, eve);

    // TEST: after decline offer, offeree's position no longer exist
    executeBattleDecline(bobID, bob);
    assertTrue(!LibMap.hasPosition(components, bobID));
    vm.expectRevert("no existing offer");
    executeBattleAccept(bob);

  }

  function testBattleOfferTimeElapses() public {
    battleOfferSetup();

    executeBattleOffer(bobID, alice);

    // TEST: when time elpases, anyone may decline offer 
    vm.warp(block.timestamp + OFFER_DURATION);
    executeBattleDecline(bobID, eve);
    assertTrue(!LibMap.hasPosition(components, bobID));
    vm.expectRevert("no existing offer");
    executeBattleAccept(bob);

  }

  function testBattleAccept() public {
    battleOfferSetup();

    executeBattleOffer(bobID, alice);

    executeBattleAccept(bob);

    // TEST: battle initiated when accept offer 
    uint256 battleID = LibBattle.playerIDToBattleID(components, aliceID);
    autoPvPBattle(battleID, alice, bob);
  }


  function battleOfferSetup() internal {
    setup();
    spawnPlayer(4, alice);
    aliceID = addressToEntity(alice);
    spawnPlayer(4, bob);
    bobID = addressToEntity(bob);
    spawnPlayer(1, eve);
    eveID = addressToEntity(eve);
  }






}