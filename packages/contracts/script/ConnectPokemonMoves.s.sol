pragma solidity ^0.8.13;

import { PokemonScript } from "./PokemonScript.s.sol";
import "../lib/forge-std/src/Script.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibPokemonClass } from "../src/libraries/LibPokemonClass.sol";

import { ClassIndexComponent, ID as ClassIndexComponentID } from "../src/components/ClassIndexComponent.sol";
import { MoveNameComponent, ID as MoveNameComponentID } from "../src/components/MoveNameComponent.sol";
import { ConnectPokemonMovesSystem, ID as ConnectPokemonMovesSystemID } from "../src/systems/ConnectPokemonMovesSystem.sol";


import { MoveInfo } from "../src/components/MoveInfoComponent.sol";
import { MoveEffect } from "../src/components/MoveEffectComponent.sol";


// source .env
// forge script script/ConnectPokemonMoves.s.sol:ConnectPokemonMovesScript --rpc-url http://localhost:8545 --broadcast

contract ConnectPokemonMovesScript is PokemonScript {

  uint256 pokemonIndex;
  string[] moveNames;

  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    pokemonIndex = 1;
    moveNames = ["Tackle", "Growl"];

    uint256[] memory moveIDs = new uint256[](moveNames.length);
    uint256 pokemonID = getPokemonIDFromIndex(pokemonIndex);
    for(uint i=0; i<moveNames.length; i++) {
      moveIDs[i] = getMoveIDFromName(moveNames[i]);
    }

    ConnectPokemonMovesSystem(system(ConnectPokemonMovesSystemID)).executeTyped(pokemonID, moveIDs);

    vm.stopBroadcast();
  }

  function getPokemonIDFromIndex(uint256 index) private view returns (uint256 pokemonID){
    pokemonID = ClassIndexComponent(getAddressById(components, ClassIndexComponentID)).getEntitiesWithValue(abi.encode(index))[0];
  }

  function getMoveIDFromName(string memory name) private view returns (uint256 moveID) {
    moveID = MoveNameComponent(getAddressById(components, MoveNameComponentID)).getEntitiesWithValue(abi.encode(name))[0];
  }

}
