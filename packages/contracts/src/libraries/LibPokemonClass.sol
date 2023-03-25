pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ClassBaseExpComponent, ID as ClassBaseExpComponentID } from "../components/ClassBaseExpComponent.sol";
import { ClassBaseStatsComponent, ID as ClassBaseStatsComponentID, PokemonStats } from "../components/ClassBaseStatsComponent.sol";
import { ClassInfoComponent, ID as ClassInfoComponentID, PokemonClassInfo } from "../components/ClassInfoComponent.sol";
import { ClassIndexComponent, ID as ClassIndexComponentID } from "../components/ClassIndexComponent.sol";
import { ClassEffortValueComponent, ID as ClassEffortValueComponentID } from "../components/ClassEffortValueComponent.sol";
import { MoveLevelPokemonComponent, ID as MoveLevelPokemonComponentID } from "../components/MoveLevelPokemonComponent.sol";

library LibPokemonClass {

  // ------- getter: classID -> pokemon class info
  function getBaseStats(IUint256Component components, uint256 classID) internal view returns(PokemonStats memory) {
    ClassBaseStatsComponent baseStats = ClassBaseStatsComponent(getAddressById(components, ClassBaseStatsComponentID));
    return baseStats.getValue(classID);
  }

  function getClassInfo(IUint256Component components, uint256 classID) internal view returns(PokemonClassInfo memory) {
    ClassInfoComponent classInfo = ClassInfoComponent(getAddressById(components, ClassInfoComponentID));
    return classInfo.getValue(classID);
  }

  function getBaseExp(IUint256Component components, uint256 classID) internal view returns(uint32) {
    ClassBaseExpComponent baseExp = ClassBaseExpComponent(getAddressById(components, ClassBaseExpComponentID));
    return baseExp.getValue(classID);
  }
}