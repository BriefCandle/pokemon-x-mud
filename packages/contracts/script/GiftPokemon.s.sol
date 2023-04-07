pragma solidity ^0.8.13;

import { PokemonScript } from "./PokemonScript.s.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { GiftPokemonSystem, ID as GiftPokemonSystemID } from "../src/systems/GiftPokemonSystem.sol";


// source .env
// forge script script/GiftPokemon.s.sol:GiftPokemonScript --rpc-url http://localhost:8545 --broadcast

contract GiftPokemonScript is PokemonScript {

  uint32 index = 1;
  uint32 level = 7;
  address player = 0x2c16204730C0d2f19931FE1c8c58ff32F36B5196;

  function run() public {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    
    setup();

    uint256 playerID = addressToEntity(player);

    GiftPokemonSystem(system(GiftPokemonSystemID)).executeTyped(index, level, playerID);

    vm.stopBroadcast();
  }


}