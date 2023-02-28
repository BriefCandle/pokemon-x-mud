// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { PokemonType } from "../PokemonType.sol";
import { LevelRate } from "../LevelRate.sol";
import { PokemonStats } from "../components/PokemonStatsComponent.sol";

import { BaseStatsComponent, ID as BaseStatsComponentID } from "../components/BaseStatsComponent.sol";
import { EffortValueComponent, ID as EffortValueComponentID } from "../components/EffortValueComponent.sol";
import { CatchRateComponent, ID as CatchRateComponentID } from "../components/CatchRateComponent.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";
import { PokemonType1Component, ID as PokemonType1ComponentID } from "../components/PokemonType1Component.sol";
import { PokemonType2Component, ID as PokemonType2ComponentID } from "../components/PokemonType2Component.sol";
import { LevelRateComponent, ID as LevelRateComponentID } from "../components/LevelRateComponent.sol";

uint256 constant ID = uint256(keccak256("system.CreatePokemonClass"));

// set BaseStats, Effort Value, CatchRate, PokemonIndex, PokemonType1, PokemonType2, LevelRate
contract CreatePokemonClassSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    (PokemonStats memory bs, PokemonStats memory ev, uint32 cr, uint32 i, 
    PokemonType type1, PokemonType type2, LevelRate lr) = abi.decode(
      args, (PokemonStats, PokemonStats, uint32, uint32, PokemonType, PokemonType, LevelRate));
    return executeTyped(bs, ev, cr, i, type1, type2, lr);
  }

  function executeTyped(PokemonStats memory bs, PokemonStats memory ev, uint32 cr, uint32 i, 
  PokemonType type1, PokemonType type2, LevelRate lr) public returns (bytes memory) {
    // need to write some authorization here
    uint256 entityID = world.getUniqueEntityId();

    BaseStatsComponent bsComp = BaseStatsComponent(getAddressById(components, BaseStatsComponentID));
    bsComp.set(entityID, bs);

    EffortValueComponent evComp = EffortValueComponent(getAddressById(components, EffortValueComponentID));
    evComp.set(entityID, ev);

    CatchRateComponent crComp = CatchRateComponent(getAddressById(components, CatchRateComponentID));
    crComp.set(entityID, cr);

    PokemonIndexComponent iComp = PokemonIndexComponent(getAddressById(components, PokemonIndexComponentID));
    iComp.set(entityID, i);

    PokemonType1Component type1Comp = PokemonType1Component(getAddressById(components, PokemonType1ComponentID));
    type1Comp.set(entityID, type1);

    PokemonType2Component type2Comp = PokemonType2Component(getAddressById(components, PokemonType2ComponentID));
    type2Comp.set(entityID, type2);

    LevelRateComponent lrComp = LevelRateComponent(getAddressById(components, LevelRateComponentID));
    lrComp.set(entityID, lr);
  }
}