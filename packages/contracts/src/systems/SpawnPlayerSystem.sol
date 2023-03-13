// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PlayerComponent, ID as PlayerComponentID } from "../components/PlayerComponent.sol";
import { LibMap } from "../libraries/LibMap.sol";
import { parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";
import { ObtainFirstPokemonSystem, ID as ObtainFirstPokemonSystemID } from "../systems/ObtainFirstPokemonSystem.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";

uint256 constant ID = uint256(keccak256("system.SpawnPlayer"));

// spawn a player to parcel(0,0)
contract SpawnPlayerSystem is System {
  
  PositionComponent position;

  constructor(IWorld _world, address _components) System(_world, _components) {
    position = PositionComponent(getAddressById(components, PositionComponentID));
  }

  function execute(bytes memory data) public returns (bytes memory) {
    uint256 playerId = addressToEntity(msg.sender);

    PlayerComponent player = PlayerComponent(getAddressById(components, PlayerComponentID));

    if (!player.has(playerId)) {
      player.set(playerId);
      spawnPlayer(playerId);
      // spawnPokemon(playerId);
    } else {
      if (!position.has(playerId)) {
        spawnPlayer(playerId);
      }
    }
  }

  // query parcel (0,0)'s 25 terrain to find empty spot to spawn
  // no obstruction && no other players
  function spawnPlayer(uint256 playerId) private {
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        Coord memory coord = Coord(int32(i), int32(j));
        if (LibMap.obstructions(world, coord).length == 0 &&
        LibMap.players(world, coord).length == 0) {
          position.set(playerId, coord);
          return;
        }
      }
    }
    revert("No place to spawn");
  }

  // // TODO: a temporary solution to gift new player a bulbasaur
  // function spawnPokemon(uint256 playerID) private {
  //   // TODO: for now, give a bulbasaur; later, client can make selection
  //   PokemonIndexComponent pokemonIndex = PokemonIndexComponent(getAddressById(components, PokemonIndexComponentID));
  //   uint32 index = 1;
  //   uint256 classID = pokemonIndex.getEntitiesWithValue(index)[0];
  //   ObtainFirstPokemonSystem obtainFirstPokemon = ObtainFirstPokemonSystem(getAddressById(world.systems(), ObtainFirstPokemonSystemID));
  //   obtainFirstPokemon.executeTyped(classID, playerID);
  // }
}