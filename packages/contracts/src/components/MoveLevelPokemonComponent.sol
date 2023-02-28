// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint256ArrayComponent } from "std-contracts/components/Uint256ArrayComponent.sol";

uint256 constant ID = uint256(keccak256("component.MoveLevelPokemon"));

// ideally, PokemonID -> MoveLevel[] where MoveLevel = {uint8 level, uint256 moveID}
// unfortunately, MUD could not support this data structure
// therefore, use uint256Array instead: [level1, level1, level1, level3, level6, level9, …]
//     - it starts with 3 for level1, increment by 3 until 48; therefore length 12+3=15
// PokemonEntityID -> MoveIndex[]
contract MoveLevelPokemonComponent is Uint256ArrayComponent {
  constructor(address world) Uint256ArrayComponent(world, ID) {}

}