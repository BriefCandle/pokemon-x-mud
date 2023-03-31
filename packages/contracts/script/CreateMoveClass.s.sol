pragma solidity ^0.8.13;

import { PokemonScript } from "./PokemonScript.s.sol";

import { CreateMoveClassSystem, ID as CreateMoveClassSystemID } from "../src/systems/CreateMoveClassSystem.sol";

import { PokemonStats } from "../src/components/PokemonStatsComponent.sol";
import { PokemonType } from "../src/PokemonType.sol";
import { MoveCategory } from "../src/MoveCategory.sol";
import { MoveTarget } from "../src/MoveTarget.sol";
import { StatusCondition } from "../src/StatusCondition.sol"; 

import { MoveInfo } from "../src/components/MoveInfoComponent.sol";
import { MoveEffect } from "../src/components/MoveEffectComponent.sol";


// source .env
// forge script script/CreateMoveClass.s.sol:CreateMoveClassScript --rpc-url http://localhost:8545 --broadcast

contract CreateMoveClassScript is PokemonScript {
  
  string[4] nameArray;
  MoveInfo[4] infoArray;
  MoveEffect[4] effectArray;

  function run() public {
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    setup();

    nameArray[0] = 'Tackle';
    infoArray[0] = MoveInfo(PokemonType.Normal, MoveCategory.Physical, 35, 40, 100);
    effectArray[0] = MoveEffect(0,0,0,0,0,0,0,0,0,0,0,MoveTarget.Foe,StatusCondition.None);

    nameArray[1] = 'Growl';
    infoArray[1] = MoveInfo(PokemonType.Grass, MoveCategory.Status, 40, 0, 100);
    effectArray[1] = MoveEffect(0,-1,0,0,0,0,0,0,0,0,0,MoveTarget.Foe, StatusCondition.None);

    nameArray[2] = 'Vine Whip';
    infoArray[2] = MoveInfo(PokemonType.Grass, MoveCategory.Physical, 10, 35, 100);
    effectArray[2] = MoveEffect(0,0,0,0,0,0,0,0,0,0,0,MoveTarget.Foe, StatusCondition.None);

    nameArray[3] = 'Leech Seed';
    infoArray[3] = MoveInfo(PokemonType.Grass, MoveCategory.Status, 10, 0, 90);
    effectArray[3] = MoveEffect(0,0,0,0,0,0,0,0,0,0,0,MoveTarget.Foe,StatusCondition.LeechSeed);

    for(uint i=0; i<nameArray.length; i++) {
      CreateMoveClassSystem(system(CreateMoveClassSystemID)).executeTyped(
        nameArray[i], infoArray[i], effectArray[i]
      );
    }

    vm.stopBroadcast();
  }
}

