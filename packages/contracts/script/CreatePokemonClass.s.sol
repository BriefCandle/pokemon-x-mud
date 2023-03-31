pragma solidity ^0.8.13;

import { PokemonScript } from "./PokemonScript.s.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";
import { CreatePokemonClassSystem, ID as CreatePokemonClassSystemID } from "../src/systems/CreatePokemonClassSystem.sol";

import { PokemonStats } from "../src/components/PokemonStatsComponent.sol";
import { PokemonType } from "../src/PokemonType.sol";
import { LevelRate } from "../src/LevelRate.sol";
import { PokemonClassInfo } from "../src/components/ClassInfoComponent.sol";

// source .env
// forge script script/CreatePokemonClass.s.sol:CreatePokemonClassScript --rpc-url http://localhost:8545 --broadcast

contract CreatePokemonClassScript is PokemonScript {

  uint32[3] baseExp_array;
  PokemonStats[3] bs_array;
  PokemonStats[3] ev_array;
  PokemonClassInfo[3] pci_array;
  uint32[3] iArray;


  function run() public {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    
    setup();

    baseExp_array = [64, 142, 263];

    bs_array[0] = PokemonStats(45,49,49,65,65,45);
    bs_array[1] = PokemonStats(60,62,63,80,80,60);
    bs_array[2] = PokemonStats(80,82,83,100,100,80);

    ev_array[0] = PokemonStats(0,0,0,1,0,0);
    ev_array[1] = PokemonStats(0,0,0,1,1,0);
    ev_array[2] = PokemonStats(0,0,0,2,1,0);

    pci_array[0] = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    pci_array[1] = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    pci_array[2] = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);

    iArray = [1,2,3];


    for(uint i=0; i<bs_array.length; i++) {
      CreatePokemonClassSystem(system(CreatePokemonClassSystemID)).executeTyped(
        baseExp_array[i], bs_array[i], ev_array[i], pci_array[i], iArray[i]);
    }

    vm.stopBroadcast();
  }


}


