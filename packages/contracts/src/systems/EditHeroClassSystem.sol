// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { RPGStats } from "components/RPGStatsComponent.sol";
import { RPGMeta } from "components/RPGMetaComponent.sol";
import { ClassHeroStatsComponent, ID as ClassHeroStatsComponentID } from "components/ClassHeroStatsComponent.sol";
import { ClassHeroMetaComponent, ID as ClassHeroMetaComponentID } from "components/ClassHeroMetaComponent.sol";


uint256 constant ID = uint256(keccak256("system.EditHeroClass"));

// might be redundant with CreateHeroClass
// also need to add proper authorization, i.e., who can edit which heroclass
contract EditHeroClassSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint256 entityID, RPGStats memory stats, RPGMeta memory meta) = abi.decode(args, (uint256, RPGStats, RPGMeta));
    return executeTyped(entityID, stats, meta);
  }

  function executeTyped(uint256 entityID, RPGStats memory stats, RPGMeta memory meta) public returns (bytes memory) {
    ClassHeroStatsComponent heroClassStats = ClassHeroStatsComponent(getAddressById(components, ClassHeroStatsComponentID));
    heroClassStats.set(entityID, stats);

    ClassHeroMetaComponent heroClassMeta = ClassHeroMetaComponent(getAddressById(components, ClassHeroMetaComponentID));
    heroClassMeta.set(entityID, meta);
  }
}