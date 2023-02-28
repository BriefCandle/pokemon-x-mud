pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";

import { CreatePokemonClassScript } from "./CreatePokemonClass.s.sol";
import { CreateMoveClassScript } from "./CreateMoveClass.s.sol";
import {ConnectPokemonMovesScript} from "./ConnectPokemonMoves.s.sol";

contract InitScript is Script {
  function run() public {
    
  }
}