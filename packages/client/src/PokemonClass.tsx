import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";



export const PokemonClass = (props:any) => {
  const {
    components: { BaseStats, EffortValue, PokemonClassInfo, PokemonIndex
    },
    world
  } = useMUD();

  const index = props.index;
  const entityID = world.entities[index]

  const bs = useComponentValue(BaseStats, index);
  const ev = useComponentValue(EffortValue, index);
  const info = useComponentValue(PokemonClassInfo,index);
  const pokemonIndex = useComponentValue(PokemonIndex, index);

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
      <div>Pokemon Index: {pokemonIndex?.value}</div>
      <div>World Index: {index.valueOf()}</div>
      <div>EntityID: {entityID.valueOf()}</div>
      <div>Base Stats: {displayStruct(bs)}</div>
      <div>Effort Value: {displayStruct(ev)}</div>
      <div>Class Info: {displayStruct(info)}</div>
    </div>
  )

}
