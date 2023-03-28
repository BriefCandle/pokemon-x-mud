// // SPDX-License-Identifier: Unlicense
// pragma solidity >=0.8.0;

// import { Deploy } from "./Deploy.sol";
// import { PokemonTest } from "./PokemonTest.t.sol"; 
// import "std-contracts/test/MudTest.t.sol";
// import { getAddressById, addressToEntity } from "solecs/utils.sol";

// import { LibBattle } from "../libraries/LibBattle.sol";
// import { LibPokemon } from "../libraries/LibPokemon.sol";
// import { LibTeam } from "../libraries/LibTeam.sol";
// import { LibRNG } from "../libraries/LibRNG.sol"; 
// import { LibArray } from "../libraries/LibArray.sol"; 
// import { LibAction } from "../libraries/LibAction.sol"; 
// import { LibMove } from "../libraries/LibMove.sol"; 


// import { PokemonStats } from "../components/PokemonStatsComponent.sol";
// import { BattleActionType } from "../BattleActionType.sol";
// import { BattleType } from "../BattleType.sol";


// import { CrawlSystem, ID as CrawlSystemID } from "../systems/CrawlSystem.sol";
// import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";

// import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
// import { TeamBattleComponent, ID as TeamBattleComponentID } from "../components/TeamBattleComponent.sol";

// contract EncounterPokeballTest is PokemonTest {

//   uint256 nounce = 0;

//   BattleSystem battleSystem;

//   constructor() PokemonTest(new Deploy()) { }

//   function testEncounterPokeball() public { 
//     setup();
//     crawlTo(Coord(0,1));
//     setupBattle();

//     uint256 aliceID = addressToEntity(alice);
//     uint256[] memory alicePokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);
//     uint alice_original_count = alicePokemonIDs.length;
//     uint alice_count;
//     uint256 battleID =  LibBattle.playerIDToBattleID(components, BattleSystemID);
//     uint256[] memory enemyPokemonIDs = LibBattle.playerIDToEnemyPokemons(components, aliceID);
//     uint256 targetID;
//     uint32 target_pre_hp;
//     uint32 target_pos_hp;

//     bool isBattleExist = LibBattle.isBattleOrderExist(components, battleID);


//     BattleActionType alice_action = BattleActionType.UsePokeball;
  
//     while (isBattleExist) {
//       alicePokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);

//       uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);

//       if (LibArray.isValueInArray(nextPokemon, alicePokemonIDs)) { 
//         targetID = enemyPokemonIDs[0];
//         // uint16 catch_rate = LibPokemon.getCatchRate(components, targetID);
//         // console.log("catch rate", catch_rate);
//         executeBattle(nextPokemon, targetID, alice_action, alice);
//         console.log("alice throws pokeball");
//         vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);

//         // uint256 precommit = LibRNG.getPrecommit(components, nextPokemon);
//         // console.log("threshold: ", uint256(blockhash(precommit)) % 256);

//         executeBattle(nextPokemon, targetID, alice_action, alice);
        
//         alicePokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);
//         alice_count = alicePokemonIDs.length;
//         console.log("alice team member count", alice_count);

//       } else {
//         console.log("alice pokemon being targeted", alicePokemonIDs[0]);
//         target_pre_hp = LibPokemon.getHP(components, alicePokemonIDs[0]);
//         executeBattle(0, 0, BattleActionType.Move0, alice);
//         vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
//         executeBattle(0, 0, BattleActionType.Move0, alice);
//         target_pos_hp = LibPokemon.getHP(components, alicePokemonIDs[0]);
//         console.log("alice pokemon 1 HP drops from ", target_pre_hp, " to ", target_pos_hp);
//       }
//       isBattleExist = LibBattle.isBattleOrderExist(components, battleID);
//     }
//   }

//   function executeBattle(uint256 pokemonID, uint256 targetID, BattleActionType action, address player) prank(player) internal {
//     battleSystem.executeTyped(pokemonID, targetID, action);
//   }

//   function crawlTo(Coord memory coord) prank(alice) internal {
//     CrawlSystem crawlS = CrawlSystem(system(CrawlSystemID));
//     crawlS.executeTyped(coord);
//   }

//   function setupBattle() internal {
//     battleSystem = BattleSystem(system(BattleSystemID));
//   }

//   function logArray(uint[] memory array) internal view {
//     for (uint i; i<array.length; i++) {
//       console.log(array[i]);
//     }
//   }

// }