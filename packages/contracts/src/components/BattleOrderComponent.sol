// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";

import { Uint256ArrayComponent } from "std-contracts/components/Uint256ArrayComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

// record turn order of one round
// 1v1 for now; could expand it later to 6v6?
// uint256[] instead?
struct BattleOrder {
  uint256 pokemon0;
  uint256 pokemon1;
}

uint256 constant ID = uint256(keccak256("component.BattleOrder"));

// battleID -> pokemonID[]
contract BattleOrderComponent is Uint256ArrayComponent {
  constructor(address world) Uint256ArrayComponent(world, ID) {}

  // function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
  //   keys = new string[](2);
  //   values = new LibTypes.SchemaValue[](2);

  //   keys[0] = "pokemon0";
  //   values[0] = LibTypes.SchemaValue.INT8;

  //   keys[1] = "pokemon1";
  //   values[1] = LibTypes.SchemaValue.INT8;
  // }

  // function set(uint256 entity, BattleOrder calldata pokemons) public virtual {
  //   set(entity, abi.encode(pokemons));
  // }

  // function getValue(uint256 entity) public view virtual returns (BattleOrder memory pokemons) {
  //   pokemons = abi.decode(getRawValue(entity), (BattleOrder));
  // }
}