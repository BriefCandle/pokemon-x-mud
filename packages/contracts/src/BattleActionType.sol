// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

enum BattleActionType {
  Move0,
  Move1,
  Move2,
  Move3,
  UsePokeball,
  UseStatsChanger,
  Switch,
  Escape,
  Skip,
  Encounter // TODO: a temporary patch to allow encounter to generate RNG
}
