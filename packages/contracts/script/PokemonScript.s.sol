pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

contract PokemonScript is Script {
  address world_address = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

  IWorld world;
  IUint256Component components;
  IUint256Component systems;
  
  function setup() internal {
    world = IWorld(world_address);
    systems = world.systems();
    components = world.components();
  }

  function system(uint256 id) public view returns (address) {
    return getAddressById(systems, id);
  }

}