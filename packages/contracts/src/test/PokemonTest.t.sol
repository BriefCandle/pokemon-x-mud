// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Deploy } from "./Deploy.sol";
import "std-contracts/test/MudTest.t.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { LibMap } from "../libraries/LibMap.sol";
import { LibBattle } from "../libraries/LibBattle.sol";
import { LibTeam } from "../libraries/LibTeam.sol";
import { LibRNG } from "../libraries/LibRNG.sol";
import { LibArray } from "../libraries/LibArray.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";


import { BattleActionType } from "../BattleActionType.sol";
import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { PokemonType } from "../PokemonType.sol";
import { MoveCategory } from "../MoveCategory.sol";
import { LevelRate } from "../LevelRate.sol";
import { PokemonClassInfo } from "../components/ClassInfoComponent.sol";
import { MoveInfo } from "../components/MoveInfoComponent.sol";
import { MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { StatusCondition } from "../StatusCondition.sol"; 
import { Parcel, parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";
import { TerrainType } from "../TerrainType.sol";

import { CreatePokemonClassSystem, ID as CreatePokemonClassSystemID } from "../systems/CreatePokemonClassSystem.sol";
import { SpawnPlayerSystem, ID as SpawnPlayerSystemID } from "../systems/SpawnPlayerSystem.sol";
import { CreateMoveClassSystem, ID as CreateMoveClassSystemID } from "../systems/CreateMoveClassSystem.sol";
import { ConnectPokemonMovesSystem, ID as ConnectPokemonMovesSystemID } from "../systems/ConnectPokemonMovesSystem.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "../systems/SpawnPokemonSystem.sol";
import { CreateParcelSystem, ID as CreateParcelSystemID } from "../systems/CreateParcelSystem.sol";
import { CreateDungeonSystem, ID as CreateDungeonSystemID } from "../systems/CreateDungeonSystem.sol";
import { CrawlSystem, ID as CrawlSystemID } from "../systems/CrawlSystem.sol";
import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";
import { GiftPokemonSystem, ID as GiftPokemonSystemID } from "../systems/GiftPokemonSystem.sol";
import { AssembleTeamSystem, ID as AssembleTeamSystemID } from "../systems/AssembleTeamSystem.sol";
import { RestoreTeamHPSystem, ID as RestoreTeamHPSystemID } from "../systems/RestoreTeamHPSystem.sol";

import { ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { MoveNameComponent, ID as MoveNameComponentID } from "../components/MoveNameComponent.sol";
import { ClassIndexComponent, ID as ClassIndexComponentID } from "../components/ClassIndexComponent.sol";

contract PokemonTest is MudTest {

  BattleSystem battleSystem;
  CrawlSystem crawlSystem;
  GiftPokemonSystem giftPokemonSystem;
  AssembleTeamSystem assembleTeamSystem;
  RestoreTeamHPSystem restoreTeamHPSystem;

  // when inherit: constructor() PokemonTest(new Deploy()) {}
  constructor(IDeploy deploy) MudTest(deploy) {}
  // constructor() MudTest(new Deploy()) {}

  function setupSystems() internal {
    battleSystem = BattleSystem(system(BattleSystemID));
    crawlSystem = CrawlSystem(system(CrawlSystemID));
    giftPokemonSystem = GiftPokemonSystem(system(GiftPokemonSystemID));
    assembleTeamSystem = AssembleTeamSystem(system(AssembleTeamSystemID));
    restoreTeamHPSystem = RestoreTeamHPSystem(system(RestoreTeamHPSystemID));
  }

  bytes zero = abi.encode(0);

  modifier prank(address prankster) {
    vm.startPrank(prankster);
    _;
    vm.stopPrank();
  }

  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------

  function createPokemonClass(uint32 baseExp, PokemonStats memory baseStats, PokemonStats memory eV, PokemonClassInfo memory classInfo, uint32 index) internal {
    CreatePokemonClassSystem createPokemonClassS = CreatePokemonClassSystem(system(CreatePokemonClassSystemID));
    createPokemonClassS.executeTyped(baseExp, baseStats, eV, classInfo, index);
  }

  function createMoveClass(string memory name, MoveInfo memory info, MoveEffect memory effect) internal {
    CreateMoveClassSystem createMoveS = CreateMoveClassSystem(system(CreateMoveClassSystemID));
    createMoveS.executeTyped(name, info, effect);
  }

  function connectPokemonMoves(uint256 pokemonID, uint256[] memory moves) internal {
    ConnectPokemonMovesSystem connectS = ConnectPokemonMovesSystem(system(ConnectPokemonMovesSystemID));
    connectS.executeTyped(pokemonID, moves);
  }

  function getMoveIDFromName(string memory name) internal view returns (uint256 moveID) {
    moveID = MoveNameComponent(getAddressById(components, MoveNameComponentID)).
      getEntitiesWithValue(abi.encode(name))[0];
  }

  function getPokemonClassIDFromIndex(uint32 index) internal view returns (uint256 pokemonClassID) {
    pokemonClassID = ClassIndexComponent(getAddressById(components, ClassIndexComponentID)).
      getEntitiesWithValue(abi.encode(index))[0];
  }


  function setupPokemon() internal {
  
    // create tackle move class
    string memory name = 'Tackle';
    MoveInfo memory info = MoveInfo(PokemonType.Normal, MoveCategory.Physical, 35, 40, 100);
    MoveEffect memory effect = MoveEffect(0,0,0,0,0,0,0,0,0,0,0,MoveTarget.Foe,StatusCondition.None);
    createMoveClass(name, info, effect);

    string memory name2 = 'Growl';
    MoveInfo memory info2 = MoveInfo(PokemonType.Grass, MoveCategory.Status, 40, 0, 100);
    MoveEffect memory effect2 = MoveEffect(0,-1,0,0,0,0,0,0,0,0,0,MoveTarget.Foe, StatusCondition.None);
    createMoveClass(name2, info2, effect2);

    // Bulbasaur pokemon class
    uint32 baseExp = 64;
    PokemonStats memory baseStats = PokemonStats(45,49,49,65,65,45);
    PokemonStats memory eV = PokemonStats(0,0,0,1,0,0);
    PokemonClassInfo memory classInfo = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    uint32 index = 1; 
    createPokemonClass(baseExp, baseStats, eV, classInfo, index);

    // connect Tackle & Growl with bulbasaur
    uint256 pokemonClassID = getPokemonClassIDFromIndex(index);
    uint256 moveID = getMoveIDFromName(name);
    uint256 moveID2 = getMoveIDFromName(name2);
    uint256[] memory moves = new uint256[](2);
    moves[0] = moveID;
    moves[1] = moveID2;
    connectPokemonMoves(pokemonClassID, moves);

    // ivysaur
    baseExp = 141;
    baseStats = PokemonStats(60,62,63,80,80,60);
    eV = PokemonStats(0,0,0,1,1,0);
    classInfo = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    index = 2;
    createPokemonClass(baseExp, baseStats, eV, classInfo, index);

    pokemonClassID = getPokemonClassIDFromIndex(index);
    connectPokemonMoves(pokemonClassID, moves);


    // Vensaur
    baseExp = 208;
    baseStats = PokemonStats(80,82,83,100,100,80);
    eV = PokemonStats(0,0,0,2,1,0);
    classInfo = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    index = 3;
    createPokemonClass(baseExp, baseStats, eV, classInfo, index);

    pokemonClassID = getPokemonClassIDFromIndex(index);
    connectPokemonMoves(pokemonClassID, moves);

    // Charmander
    baseExp = 65;
    baseStats = PokemonStats(39,52,43,60,50,65);
    eV = PokemonStats(0,0,0,0,0,1);
    classInfo = PokemonClassInfo(45,PokemonType.Fire,PokemonType.None,LevelRate.MediumSlow);
    index = 4;
    createPokemonClass(baseExp, baseStats, eV, classInfo, index);

    pokemonClassID = getPokemonClassIDFromIndex(index);
    connectPokemonMoves(pokemonClassID, moves);
    

  }


  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------
  function spawnPlayer(uint32 index, address player) prank(player) internal {
    SpawnPlayerSystem spawnPlayerS = SpawnPlayerSystem(system(SpawnPlayerSystemID));
    spawnPlayerS.executeTyped(index);
    Coord memory player_position = LibMap.getPosition(components, addressToEntity(player));
    console.log("player ", player, uint32(player_position.x), uint32(player_position.y));
  }

  // -------------- SETUP PARCEL AND ENCOUNTERABLE --------------

  // create an all-tall-grass parcel that is encounterable
  function createParcel() internal {
    int32 x_p = 0;
    int32 y_p = 0;
    TerrainType G = TerrainType.Grass;
    TerrainType T = TerrainType.GrassTall;
    TerrainType N = TerrainType.Nurse;
    TerrainType P = TerrainType.PC;
    TerrainType L = TerrainType.LevelCheck1;
    TerrainType S = TerrainType.Spawn;
    TerrainType[parcelHeight][parcelWidth] memory map = [
      [G, G, G, G, S],
      [G, G, G, G, N],
      [G, G, G, G, P],
      [T, T, T, L, L],
      [T, T, T, L, L]
    ];
    bytes memory terrain = new bytes(parcelWidth * parcelHeight);
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        TerrainType terrainType = map[j][i];
        terrain[(j * parcelWidth) + i] = bytes1(uint8(terrainType));
      }
    }
    CreateParcelSystem createParcelS = CreateParcelSystem(system(CreateParcelSystemID));
    createParcelS.executeTyped(x_p,y_p,terrain);
  }

  function createDungeon() internal {
    Coord memory parcel_coord = Coord(0,0);
    uint256 parcelID = LibMap.parcelID(world, parcel_coord)[0];
    console.log(parcelID, "parcel created into dungeon");
    uint32 level= 5;
    uint32[] memory indexes = new uint32[](1);
    indexes[0] = 1;
    CreateDungeonSystem(system(CreateDungeonSystemID)).executeTyped(parcelID, level, indexes);
    // Coord memory coord = Coord(0,1);
    // parcel_coord = LibMap.positionCoordToParcelCoord(coord);
    // parcelID = LibMap.parcelID(world, parcel_coord)[0];
    // // parcelID = LibMap.dungeonParcelID(world, parcel_coord)[0];
    // uint32 index = LibMap.getDungeonPokemons(components, parcelID)[0];
    // level = LibMap.getDungeonLevel(components, parcelID);
  }

  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------

  function setup() internal {
    setupSystems();
    setupPokemon();
    createParcel();
    createDungeon();
    // spawnPlayer(1, alice);
    // spawnPlayer(1, bob);
  }


  function logArray(uint[] memory array, string memory array_name) internal view {
    for (uint i; i<array.length; i++) {
      console.log(array_name, i, ": ", array[i]);
    }
  }

  function executeBattle(uint256 battleID, uint256 targetID, BattleActionType action, address player) prank(player) internal {
    battleSystem.executeTyped(battleID, targetID, action);
  }

  function crawlTo(Coord memory coord, address player) prank(player) internal {
    crawlSystem.executeTyped(coord);
  }

  function exectueGiftPokemon(uint32 index, uint32 level, uint256 playerID) internal returns(uint256) {
    return abi.decode(giftPokemonSystem.executeTyped(index, level, playerID), (uint256));
  }

  function executeAssembleTeam(uint256[] memory pokemonIDs, Coord memory coord, address player) prank(player) internal {
    assembleTeamSystem.executeTyped(pokemonIDs, coord);
  }

  function autoPvEBattle(uint256 battleID, address player) internal {
    uint256 playerID = addressToEntity(player);
    uint256 nextPokemon;
    uint256[] memory playerPokemonIDs;
    uint256 targetID;
    console.log("--------- Encounter Attack Begins ---------");   
    while(LibBattle.isBattleOrderExist(components, battleID)) {
      nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
      playerPokemonIDs = LibTeam.playerIDToTeamPokemonIDs(components, playerID);
      if (LibArray.isValueInArray(nextPokemon, playerPokemonIDs)) {
        targetID = LibBattle.playerIDToEnemyPokemons(components, playerID)[0];
      } else {
        targetID = LibBattle.playerIDToEnemyPokemons(components, BattleSystemID)[0];
      }
      executeBattle(battleID, targetID, BattleActionType.Move0, alice); 
      vm.roll(block.number + LibRNG.WAIT_BLOCKS + 1);
      executeBattle(battleID, targetID, BattleActionType.Move0, alice); 
      console.log(targetID, "HP: ", LibPokemon.getHP(components, targetID));
    }
    console.log("--------- Encounter Attack Ends ---------");   
    uint256[] memory team_pokemons = LibTeam.playerIDToTeamPokemonIDs(components, playerID);
    logArray(team_pokemons, "alice pokemon");
  }

  function executeRestoreTeamHP(Coord memory coord, address player) prank(player) internal {
    restoreTeamHPSystem.executeTyped(coord);
  }

}