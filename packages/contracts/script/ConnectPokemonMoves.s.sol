pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import { getAddressById } from "solecs/utils.sol";


import { MoveInfo } from "../src/components/MoveInfoComponent.sol";
import { MoveEffect } from "../src/components/MoveEffectComponent.sol";


// source .env
// forge script script/ConnectPokemonMoves.s.sol:ConnectPokemonMovesScript --rpc-url http://localhost:8545 --broadcast

contract ConnectPokemonMovesScript is Script {

  address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
  address PokemonIndexComponent = 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707;
  address MoveNameComponent = 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318;
  address ConnectPokemonMovesSystem = 0x09635F643e140090A9A8Dcd712eD6285858ceBef;
  
  uint256 pokemonIndex;
  string[] moveNames;

  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    pokemonIndex = 1;
    moveNames = ["Tackle", "Growl"];

    uint256[] memory moveIDs = new uint256[](moveNames.length);
    uint256 pokemonID = getPokemonIDFromIndex(pokemonIndex);
    for(uint i=0; i<moveNames.length; i++) {
      moveIDs[i] = getMoveIDFromName(moveNames[i]);
    }

    IConnetPokemonMovesSystem(ConnectPokemonMovesSystem).executeTyped(pokemonID, moveIDs);

    vm.stopBroadcast();
  }

  function getPokemonIDFromIndex(uint256 index) private view returns (uint256 pokemonID){
    pokemonID = IComponent(PokemonIndexComponent).getEntitiesWithValue(abi.encode(index))[0];
  }

  function getMoveIDFromName(string memory name) private view returns (uint256 moveID) {
    moveID = IComponent(MoveNameComponent).getEntitiesWithValue(abi.encode(name))[0];
  }

  // function getMoveIDsFromNames(string[15])
}

interface IConnetPokemonMovesSystem {
  function executeTyped(uint256 pokemonID, uint256[] memory moves) external returns (bytes memory);
}

interface IComponent {
  function has(uint256 entity) external view returns (bool);

  function getRawValue(uint256 entity) external view returns (bytes memory);

  function getEntities() external view returns (uint256[] memory);

  function getEntitiesWithValue(bytes memory value) external view returns (uint256[] memory);
}

interface IWorld {
  function getUniqueEntityId() external view returns (uint256);
}

