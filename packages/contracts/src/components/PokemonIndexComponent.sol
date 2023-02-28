// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";

uint256 constant ID = uint256(keccak256("component.PokemonIndex"));

//---- inherent to a pokemon class ----
// ideally, uint16
// used to display pokemon on the front-end
contract PokemonIndexComponent is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}
}
