// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// for Pokemon gen II
enum StatusCondition {
  None,
  // non-volatile
  Burn,
  Freeze,
  Paralysis,
  Poison,
  BadPoison,
  // volatile
  Sleep,
  Confusion,
  LeechSeed
}