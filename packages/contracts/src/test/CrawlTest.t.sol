// // SPDX-License-Identifier: Unlicense
// pragma solidity >=0.8.0;

// import { Deploy } from "./Deploy.sol";
// import { PokemonTest } from "./PokemonTest.t.sol"; 
// import "std-contracts/test/MudTest.t.sol";
// import { getAddressById, addressToEntity } from "solecs/utils.sol";

// import { Coord } from "../components/PositionComponent.sol";
// import { BattleActionType } from "../BattleActionType.sol";
// import { ID as BattleSystemID } from "../systems/BattleSystem.sol";
// import { MAX_DURATION } from "../components/BattleActionTimestampComponent.sol";

// import { LibBattle } from "../libraries/LibBattle.sol";
// import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";
// import { LibPokemon } from "../libraries/LibPokemon.sol";
// import { LibTeam } from "../libraries/LibTeam.sol";
// import { LibRNG } from "../libraries/LibRNG.sol"; 
// import { LibArray } from "../libraries/LibArray.sol"; 
// import { LibAction } from "../libraries/LibAction.sol"; 
// import { LibMove } from "../libraries/LibMove.sol"; 
// import { LibMap } from "../libraries/LibMap.sol"; 

// contract CrawlTest is PokemonTest {

//   constructor() PokemonTest(new Deploy()) { }

//   function testInteractPC() public {
//     setup();
//     spawnPlayer(1, alice);
//     uint256 aliceID = addressToEntity(alice);
//     exectueGiftPokemon(2, 5, aliceID);
//     // get a length 4 array instead of using playerIDToTeamPokemonIDs
//     uint256[] memory team_pokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID); 
//     uint256[] memory owned_pokemonIDs = LibOwnedBy.getOwnedPokemon(world, aliceID);
//     assertTrue(team_pokemonIDs[0] != owned_pokemonIDs[0]);
//     team_pokemonIDs[0] = owned_pokemonIDs[0];

//     vm.expectRevert("PC not in coord");
//     executeAssembleTeam(team_pokemonIDs, Coord(1,0), alice);
//     console.log("cannot log onto PC");

//     crawlTo(Coord(1,0), alice);
//     crawlTo(Coord(2,0), alice);
//     crawlTo(Coord(3,0), alice);
//     crawlTo(Coord(3,1), alice);
//     vm.expectRevert("PC not in adjacent space");
//     executeAssembleTeam(team_pokemonIDs, Coord(4,2), alice);
//     crawlTo(Coord(3,2), alice);
//     console.log("move to (3,2)");

//     executeAssembleTeam(team_pokemonIDs, Coord(4,2), alice);
//     uint256[] memory team_pokemonIDs_new = LibTeam.playerIDToTeamPokemonIDs(components, aliceID);
//     assertTrue(team_pokemonIDs_new[0] == team_pokemonIDs[0]);
//     console.log("success: log onto PC and change team composition");
//   }

//   function testInteractNurse() public {
//     setup();
//     spawnPlayer(1, alice);
//     uint256 aliceID = addressToEntity(alice);
//     uint256 pokemonID = LibTeam.playerIDToTeamPokemonIDs(components, aliceID)[0];
//     uint32 HP = LibPokemon.getHP(components, pokemonID);
//     console.log("pokemon's HP is ", HP);

//     crawlTo(Coord(0,1), alice);
//     crawlTo(Coord(0,2), alice);
//     crawlTo(Coord(0,3), alice);
//     uint256 battleID =  LibBattle.playerIDToBattleID(components, aliceID);
//     autoPvEBattle(battleID, alice);

//     HP = LibPokemon.getHP(components, pokemonID);
//     console.log("pokemon's HP is ", HP);
  
//     vm.expectRevert("nurse not in coord");
//     executeRestoreTeamHP(Coord(1,3), alice);
//     console.log("cannot talk to nurse");

//     crawlTo(Coord(0,2), alice);
//     crawlTo(Coord(0,1), alice);
//     crawlTo(Coord(1,1), alice);
//     crawlTo(Coord(2,1), alice);
//     vm.expectRevert("nurse not in adjacent space");
//     executeRestoreTeamHP(Coord(4,1), alice);

//     crawlTo(Coord(3,1), alice);
//     console.log("success: crawls and interacts with nurse");
//     executeRestoreTeamHP(Coord(4,1), alice);
//     HP = LibPokemon.getHP(components, pokemonID);
//     uint32 level = LibPokemon.getLevel(components, pokemonID);
//     console.log("pokemon's HP is ", HP);
//     console.log("level", level);
//   }

//   function testInteractLevelCheck() public {
//     setup();
//     spawnPlayer(1, alice);
//     uint256 aliceID = addressToEntity(alice);

//     // 1) low level team can enter
//     crawlTo(Coord(1,0), alice);
//     crawlTo(Coord(2,0), alice);
//     crawlTo(Coord(3,0), alice);
//     crawlTo(Coord(3,1), alice);
//     crawlTo(Coord(3,2), alice);
//     crawlTo(Coord(3,3), alice);
//     crawlTo(Coord(3,4), alice);

//     // 2) high level team cannot enter
//     crawlTo(Coord(3,3), alice);
//     crawlTo(Coord(3,2), alice);
//     exectueGiftPokemon(2, 11, aliceID);
//     uint256[] memory team_pokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID); 
//     uint256[] memory owned_pokemonIDs = LibOwnedBy.getOwnedPokemon(world, aliceID);
//     team_pokemonIDs[0] = owned_pokemonIDs[0];
//     executeAssembleTeam(team_pokemonIDs, Coord(4,2), alice);
//     team_pokemonIDs = LibTeam.playerIDToTeamPokemons(components, aliceID);
//     assertTrue(LibPokemon.getLevel(components, team_pokemonIDs[0])>10);

//     vm.expectRevert("pokemon level too high");
//     crawlTo(Coord(3,3), alice);

//   }


// }