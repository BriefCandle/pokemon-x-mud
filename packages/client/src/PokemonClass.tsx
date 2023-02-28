import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";



export const PokemonClass = (props:any) => {
  const {
    components: { BaseStats, EffortValue, CatchRate, 
      LevelRate, PokemonIndex, PokemonType1, PokemonType2 
    },
    world
  } = useMUD();

  const index = props.index;
  const entityID = world.entities[index]

  const bs = useComponentValue(BaseStats, index);
  const ev = useComponentValue(EffortValue, index);
  const cr = useComponentValue(CatchRate, index);
  const lr = useComponentValue(LevelRate, index);
  const i = useComponentValue(PokemonIndex, index);
  const type1 = useComponentValue(PokemonType1, index);
  const type2 = useComponentValue(PokemonType2, index);

  const displayStruct = (struct: any) => {
    const entries = Object.entries(struct);
    return (
      <div>
        {entries.map(([key, value])=> (
          <span key={key}>
            {key}:{value} &nbsp;
          </span>
        ))}
      </div>
    )
  }

  return (
    <div>
      <div>Pokemon Index: {i?.value}</div>
      <div>World Index: {index.valueOf()}</div>
      <div>EntityID: {entityID.valueOf()}</div>
      <div>Base Stats: {displayStruct(bs)}</div>
      <div>Effort Value: {displayStruct(ev)}</div>
      <div>Catch Rate: {cr?.value}</div>
      <div>Level Rate: {lr?.value}</div>
      <div>Type 1: {type1?.value}</div>
      <div>Type 2: {type2?.value}</div>
    </div>
  )

}
