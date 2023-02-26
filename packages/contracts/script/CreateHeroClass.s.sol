pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import { RPGStats } from "../src/components/RPGStatsComponent.sol";
import { RPGMeta } from "../src/components/RPGMetaComponent.sol";

// source .env
// forge script script/CreateHeroClass.s.sol:CreateHeroClassScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
// forge script script/CreateHeroClass.s.sol:CreateHeroClassScript --rpc-url http://localhost:8545 --broadcast

contract CreateHeroClassScript is Script {

  address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
  address CreateHeroClassSystem = 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9;
  
  RPGStats[2] statsArray;
  RPGMeta[2] metaArray;

  function run() public {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    statsArray[0] = RPGStats(13,1,1,1,1,1,1,1);
    statsArray[1] = RPGStats(14,2,2,2,1,1,1,1);
    metaArray[0] = RPGMeta('Occultist', 'blahblah', 'https://static.wikia.nocookie.net/darkestdungeon_gamepedia/images/2/21/Occultist1.png','');
    metaArray[1] = RPGMeta('Crusader', 'blah', 'https://static.wikia.nocookie.net/darkestdungeon_gamepedia/images/3/30/Crusader1.png','');
    for(uint i=0; i<statsArray.length; i++) {
      ICreateHeroClassSystem(CreateHeroClassSystem).executeTyped(statsArray[i], metaArray[i]);
    }

    vm.stopBroadcast();



  }
}

interface ICreateHeroClassSystem {
  function executeTyped(RPGStats memory stats, RPGMeta memory meta) external returns (bytes memory);
}

interface IWorld {
  function getUniqueEntityId() external view returns (uint256);
}

