// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { PokemonType } from "../PokemonType.sol";
import { LevelRate } from "../LevelRate.sol";
import { PokemonStats } from "../components/PokemonStatsComponent.sol";

import { ClassBaseExpComponent, ID as ClassBaseExpComponentID } from "../components/ClassBaseExpComponent.sol";
import { ClassInfoComponent, ID as ClassInfoComponentID, PokemonClassInfo } from "../components/ClassInfoComponent.sol";
import { ClassBaseStatsComponent, ID as ClassBaseStatsComponentID } from "../components/ClassBaseStatsComponent.sol";
import { ClassEffortValueComponent, ID as ClassEffortValueComponentID } from "../components/ClassEffortValueComponent.sol";
import { ClassIndexComponent, ID as ClassIndexComponentID } from "../components/ClassIndexComponent.sol";

uint256 constant ID = uint256(keccak256("system.CreatePokemonClass"));

// set BaseStats, Effort Value, CatchRate, PokemonIndex, PokemonType1, PokemonType2, LevelRate
contract CreatePokemonClassSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (uint32 baseExp, PokemonStats memory bs, PokemonStats memory ev, PokemonClassInfo memory info, uint32 index) = abi.decode(
      args, (uint32, PokemonStats, PokemonStats, PokemonClassInfo, uint32));
    return executeTyped(baseExp, bs, ev, info, index);
  }

  function executeTyped(uint32 baseExp, PokemonStats memory bs, PokemonStats memory ev, PokemonClassInfo memory info, uint32 index) public returns (bytes memory) {
    // TODO: need to write some authorization here
    uint256 entityID = world.getUniqueEntityId();

    ClassBaseExpComponent baseExpComp = ClassBaseExpComponent(getAddressById(components, ClassBaseExpComponentID));
    baseExpComp.set(entityID, baseExp);

    ClassBaseStatsComponent bsComp = ClassBaseStatsComponent(getAddressById(components, ClassBaseStatsComponentID));
    bsComp.set(entityID, bs);

    ClassEffortValueComponent evComp = ClassEffortValueComponent(getAddressById(components, ClassEffortValueComponentID));
    evComp.set(entityID, ev);

    ClassInfoComponent pciComp = ClassInfoComponent(getAddressById(components, ClassInfoComponentID));
    pciComp.set(entityID, info);
    // CatchRateComponent crComp = CatchRateComponent(getAddressById(components, CatchRateComponentID));
    // crComp.set(entityID, cr);

    ClassIndexComponent iComp = ClassIndexComponent(getAddressById(components, ClassIndexComponentID));
    iComp.set(entityID, index);
  }

}