import { defineComponent, Type } from "@latticexyz/recs";
import { defineNumberComponent, defineStringComponent } from "@latticexyz/std-client";
// import {
//   defineBoolComponent,
//   defineCoordComponent,
//   defineNumberComponent,
//   defineStringComponent,
// } from "@latticexyz/std-client";
import { world } from "./mud/world";
// import { MoveTarget, StatusCondition, PokemonType, MoveCategory } from "./PokemonTypes";

export const PokemonStats = {
  HP: Type.Number, // max health
  ATK: Type.Number,  // attack
  DEF: Type.Number,  // defence
  SPATK: Type.Number,  // special attack
  SPDEF: Type.Number,  // special defence
  SPD: Type.Number,  // speed
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
} as const;

export const MoveInfo = {
  TYP: Type.Number, //PokemonType, // move type
  CTG: Type.Number, //MoveCategory, // move category
  PP: Type.Number,
  PWR: Type.Number, // power
  ACR: Type.Number // accuracy
}

export const MoveLevels = {value: Type.NumberArray};

export const components = {
  // // move class components:
  MoveEffect: defineComponent(world,
    MoveEffect,
    {id: "MoveEffect", metadata: {contractId: "component.MoveEffect"}
    }
  ),
  MoveInfo: defineComponent(world,
    MoveInfo,
    {id: "MoveInfo", metadata: {contractId: "component.MoveInfo"}}
  ),
  MoveName: defineStringComponent(world, {
    metadata: {contractId: "component.MoveName"}
  }),
  MoveLevelPokemon: defineComponent(world,
    MoveLevels,
    {id: "MoveLevelPokemon", metadata: {contractId: "component.MoveLevelPokemon"}
    }  
  ),
  // pokemon class components: 
  BaseStats: defineComponent(world,
    PokemonStats, 
    {id: "BaseStats", metadata: {contractId: "component.BaseStats"}}
  ),
  EffortValue: defineComponent(world,
    PokemonStats, 
    {id: "EffortValue", metadata: {contractId: "component.EffortValue"},}
  ),
  CatchRate: defineNumberComponent(world, {
    metadata: {
      contractId: "component.CatchRate"
    }
  }),
  LevelRate: defineNumberComponent(world, {
    metadata: {
      contractId: "component.LevelRate"
    }
  }),
  PokemonIndex: defineNumberComponent(world, {
    metadata: {
      contractId: "component.PokemonIndex"
    }
  }),
  PokemonType1: defineNumberComponent(world, {
    metadata: {
      contractId: "component.PokemonType1"
    }
  }),
  PokemonType2: defineNumberComponent(world, {
    metadata: {
      contractId: "component.PokemonType2"
    }
  })
}

export const clientComponents = {};