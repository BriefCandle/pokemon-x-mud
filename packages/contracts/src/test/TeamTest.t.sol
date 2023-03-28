// // SPDX-License-Identifier: Unlicense
// pragma solidity >=0.8.0;

// import { Deploy } from "./Deploy.sol";
// import { PokemonTest } from "./PokemonTest.t.sol"; 
// import "std-contracts/test/MudTest.t.sol";
// import { getAddressById, addressToEntity } from "solecs/utils.sol";

// import { LibBattle } from "../libraries/LibBattle.sol";
// import { LibOwnedBy } from "../libraries/LibOwnedBy.sol";
// import { LibPokemon } from "../libraries/LibPokemon.sol";
// import { LibTeam } from "../libraries/LibTeam.sol";
// import { LibRNG } from "../libraries/LibRNG.sol"; 
// import { LibArray } from "../libraries/LibArray.sol"; 
// import { LibAction } from "../libraries/LibAction.sol"; 
// import { LibMove } from "../libraries/LibMove.sol"; 

// import { PokemonStats } from "../components/PokemonStatsComponent.sol";
// import { BattleActionType } from "../BattleActionType.sol";
// import { BattleType } from "../BattleType.sol";
// import { Coord } from "../components/PositionComponent.sol";

// import { CrawlSystem, ID as CrawlSystemID } from "../systems/CrawlSystem.sol";
// import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";
// import { GiftPokemonSystem, ID as GiftPokemonSystemID } from "../systems/GiftPokemonSystem.sol";
// import { AssembleTeamSystem, ID as AssembleTeamSystemID } from "../systems/AssembleTeamSystem.sol";

// contract TeamTest is PokemonTest {

//   constructor() PokemonTest(new Deploy()) { }

//   function testAssembleTeam() public {
//     setup();
//     uint256 aliceID = addressToEntity(alice);
//     uint256 alice_teamID = LibTeam.playerIDToTeamID(components, aliceID);
//     uint256[] memory ownedPokemons = LibOwnedBy.getOwnedPokemon(world, addressToEntity(alice));
//     assertEq(ownedPokemons.length, 0);
    
//     // gift one to alice
//     exectueGiftPokemon(4, 5, aliceID);
//     ownedPokemons = LibOwnedBy.getOwnedPokemon(world, aliceID);
//     assertEq(ownedPokemons.length, 1);

//     // gift second one to alice
//     exectueGiftPokemon(1, 10, aliceID);
//     ownedPokemons = LibOwnedBy.getOwnedPokemon(world, aliceID);
//     assertEq(ownedPokemons.length, 2);

//     // set team to 0 size
//     uint256[] memory team_pokemons = new uint256[](4);
//     for (uint i =0; i<team_pokemons.length; i++) team_pokemons[i] = 0;
//     uint team_size = LibTeam.playerIDToTeamPokemonIDs(components, aliceID).length;
//     executeAssembleTeam(team_pokemons, alice);
//     ownedPokemons = LibOwnedBy.getOwnedPokemon(world, aliceID);
//     assertEq(ownedPokemons.length, 2+team_size);
//     assertEq(LibTeam.playerIDToTeamPokemonIDs(components, aliceID).length, 0);
//     uint256[] memory teamOwnedPokemons = LibOwnedBy.getOwnedPokemon(world, alice_teamID);
//     assertEq(teamOwnedPokemons.length, 0);
    
//     if (ownedPokemons.length == 4) {
//       executeAssembleTeam(ownedPokemons, alice);
//       assertEq(LibTeam.playerIDToTeamPokemonIDs(components, aliceID).length, 4);
//     }

//     // alice try assign bob's pokemon to alice's group
//     uint256 bobID = addressToEntity(bob);
//     exectueGiftPokemon(1, 5, bobID);  
//     uint256 bob_pokemon = LibOwnedBy.getOwnedPokemon(world, bobID)[0];
//     console.log("bob's pokemon: ", bob_pokemon);
//     team_pokemons[0] = bob_pokemon;
//     vm.expectRevert("Assemble Team: not owned by player");
//     executeAssembleTeam(team_pokemons, alice);


//     // console.log(ownedPokemons[0]);
//     // crawlTo(Coord(0,1), alice);

//   }



// }