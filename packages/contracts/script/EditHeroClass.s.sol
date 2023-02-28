// pragma solidity ^0.8.13;

// import "../lib/forge-std/src/Script.sol";
// import { RPGStats } from "../src/components/RPGStatsComponent.sol";
// import { RPGMeta } from "../src/components/RPGMetaComponent.sol";

// // source .env
// // forge script script/CreateHeroClass.s.sol:CreateHeroClassScript --broadcast --verify --rpc-url ${GOERLI_RPC_URL}
// // forge script script/CreateHeroClass.s.sol:CreateHeroClassScript --rpc-url http://localhost:8545 --broadcast

// contract EditHeroClassScript is Script {

//   address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
//   address EditHeroClassSystem = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6;
  

//   function run() public {
//     // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//     vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

//     uint256 entityID = 10;
//     RPGStats memory stats = RPGStats(0,1,1,1,1,1,1,1);
//     RPGMeta memory meta = RPGMeta('xxx', 'blahblah', 'https://static.wikia.nocookie.net/darkestdungeon_gamepedia/images/2/21/Occultist1.png','');

//     IEditHeroClassSystem(EditHeroClassSystem).executeTyped(entityID, stats, meta);

//     vm.stopBroadcast();



//   }
// }

// interface IEditHeroClassSystem {
//   function executeTyped(uint256 entityID, RPGStats memory stats, RPGMeta memory meta) external returns (bytes memory);
// }

// interface IWorld {
//   function getUniqueEntityId() external view returns (uint256);
// }

