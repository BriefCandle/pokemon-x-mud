// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "std-contracts/components/CoordComponent.sol";

uint256 constant ID = uint256(keccak256("component.ParcelCoord"));

contract ParcelCoordComponent is CoordComponent {
  constructor(address world) CoordComponent(world, ID) {}
}