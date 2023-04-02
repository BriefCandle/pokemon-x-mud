import { defineComponent, Type } from "@latticexyz/recs";
import { defineNumberComponent, defineStringComponent, defineCoordComponent, defineBoolComponent } from "@latticexyz/std-client";

import { world } from "./world";
import { overridableComponent } from "@latticexyz/recs";
// import { MoveTarget, StatusCondition, PokemonType, MoveCategory } from "./PokemonTypes";

export const Parcel = {
  x: Type.Number,
  y: Type.Number,
  terrain: Type.String
}

export const PokemonInstance = {
  classID: Type.Number, // refer to pokemon classID
  move0: Type.Number,
  move1: Type.Number,
  move2: Type.Number,
  move3: Type.Number,
  heldItem: Type.Number, // refer to heldItem instance ID
  exp: Type.Number,
  level: Type.Number,
  currentHP: Type.Number,
  sc: Type.Number, //StatusCondition
  ATK: Type.Number,  // attack; A
  DEF: Type.Number, // defence; B
  SPATK: Type.Number, // special attack; C
  SPDEF: Type.Number, // special defence; D
  SPD: Type.Number, // speed; S
  CRT: Type.Number, // critical rate
  ACC: Type.Number, // accuracy
  EVA: Type.Number, // evasive
  duration: Type.Number
}

export const PokemonStats = {
  HP: Type.Number, // max health
  ATK: Type.Number,  // attack
  DEF: Type.Number,  // defence
  SPATK: Type.Number,  // special attack
  SPDEF: Type.Number,  // special defence
  SPD: Type.Number,  // speed
}

export const PokemonClassInfo = {
  catchRate: Type.Number,
  type1: Type.Number,
  type2: Type.Number,
  levelRate: Type.Number
}

export const MoveEffect = {
  HP: Type.Number,  // health points
  ATK: Type.Number,  // attack; A
  DEF: Type.Number, // defence; B
  SPATK: Type.Number, // special attack; C
  SPDEF: Type.Number, // special defence; D
  SPD: Type.Number, // speed; S
  CRT: Type.Number, // critical rate
  ACC: Type.Number, // accuracy
  EVA: Type.Number, // evasive
  chance: Type.Number, 
  duration: Type.Number, // duration is not for sc; 0 means across battle
  target: Type.Number,// MoveTarget,
  sc: Type.Number //StatusCondition
};

export const MoveInfo = {
  TYP: Type.Number, //PokemonType, // move type
  CTG: Type.Number, //MoveCategory, // move category
  PP: Type.Number,
  PWR: Type.Number, // power
  ACR: Type.Number // accuracy
}

// export const BattleStats = { }

export const MoveLevels = {value: Type.NumberArray};

export const PokemonMoves = {value: Type.NumberArray};


export const components = {
  Encounter: defineNumberComponent(world, {
    metadata: {contractId: "component.Encounter"}
  }),
  // crawl, position components:
  Parcel: defineComponent(world,
    Parcel,
    {id: "Parcel", metadata: {contractId: "component.Parcel"}}
  ),
  ParcelCoord: defineComponent(world,
    Parcel,
    {id: "ParcelCoord", metadata: {contractId: "component.ParcelCoord"}}
  ),
  Player: defineBoolComponent(world, {
    metadata:{contractId: "component.Player"}
  }),
  Position: overridableComponent(
    defineCoordComponent(world,{
      metadata:{contractId: "component.Position"}
    })
  ),

  // ----- Pokemon instance components: ----- 
  // PokemonBattleStats
  PokemonClassID: defineNumberComponent(world, {
    metadata: {contractId: "component.PokemonClassID"}
  }),
  PokemonEV: defineComponent(world,
    PokemonStats, 
    {id: "PokemonEV", metadata: {contractId: "component.PokemonEV"},}
  ),
  PokemonExp: defineNumberComponent(world, {
    metadata: {contractId: "component.PokemonExp"}
  }),  
  PokemonHP: defineNumberComponent(world, {
    metadata: {contractId: "component.PokemonHP"}
  }),
  PokemonItem: defineNumberComponent(world, {
    metadata: {contractId: "component.PokemonItem"}
  }),
  PokemonLevel: defineNumberComponent(world, {
    metadata: {contractId: "component.PokemonLevel"}
  }),
  PokemonMoves: defineComponent(world,
    PokemonMoves,
    {id: "PokemonMoves", metadata: {contractId: "component.PokemonMoves"}}  
  ),  
  PokemonNickname: defineStringComponent(world, {
    metadata: {contractId: "component.PokemonNickname"}
  }),

  // ----- move class components: -----
  MoveEffect: defineComponent(world,
    MoveEffect,
    {id: "MoveEffect", metadata: {contractId: "component.MoveEffect"}}
  ),
  MoveInfo: defineComponent(world,
    MoveInfo,
    {id: "MoveInfo", metadata: {contractId: "component.MoveInfo"}}
  ),
  MoveLevelPokemon: defineComponent(world,
    MoveLevels,
    {id: "MoveLevelPokemon", metadata: {contractId: "component.MoveLevelPokemon"}
    }  
  ),  
  MoveName: defineStringComponent(world, {
    metadata: {contractId: "component.MoveName"}
  }),

  // ----- pokemon class components: -----
  ClassBaseExp: defineNumberComponent(world, {
    metadata: {
      contractId: "component.ClassBaseExp"
    }
  }),
  ClassBaseStats: defineComponent(world,
    PokemonStats, 
    {id: "ClassBaseStats", metadata: {contractId: "component.ClassBaseStats"}}
  ),
  ClassEffortValue: defineComponent(world,
    PokemonStats, 
    {id: "ClassEffortValue", metadata: {contractId: "component.ClassEffortValue"},}
  ),
  ClassInfo: defineComponent(world,
    PokemonClassInfo, 
    {id: "ClassInfo", metadata: {contractId: "component.ClassInfo"},}
  ),
  ClassIndex: defineNumberComponent(world, {
    metadata: {
      contractId: "component.ClassIndex"
    }
  })
}

export const clientComponents = {};