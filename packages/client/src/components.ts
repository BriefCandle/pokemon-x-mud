import { defineComponent, Type } from "@latticexyz/recs";
// import {
//   defineBoolComponent,
//   defineCoordComponent,
//   defineNumberComponent,
//   defineStringComponent,
// } from "@latticexyz/std-client";
import { world } from "./mud/world";

export const RPGStats = {
  MAXHLTH: Type.Number, // max health
  DMG: Type.Number,  // damage
  SPD: Type.Number,  // speed
  PRT: Type.Number,  // protection
  CRT: Type.Number,  // critical
  ACR: Type.Number,  // accuracy
  DDG: Type.Number,  // dodge
  DRN: Type.Number,  // duration; 0 means permanent, 1 shall prompt deletion of stats
}

export const RPGMeta = {
  name: Type.String,
  description: Type.String,
  url: Type.String,
  others: Type.String
}

export const components = {
  ClassHeroStats: defineComponent(
    world,
    RPGStats, 
    {
      id: "ClassHeroStats",
      metadata: {contractId: "component.ClassHeroStats"},
    }
  ),
  ClassHeroMeta: defineComponent(
    world,
    RPGMeta, 
    {
      id: "ClassHeroMeta",
      metadata: {contractId: "component.ClassHeroMeta"},
    }
  )
}

export const clientComponents = {};