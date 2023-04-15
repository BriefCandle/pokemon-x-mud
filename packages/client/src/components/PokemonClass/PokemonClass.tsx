import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "../../mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";
import { DisplayStruct } from "./PokemonMoves";
import { LoadPokemonImage, PokemonImageType } from "../PokemonInstance/loadPokemonImage";

export const PokemonClass = (props:any) => {
  const {
    components: { ClassBaseStats, ClassEffortValue, ClassInfo, ClassIndex
    },
    world
  } = useMUD();

  const index = props.index;
  const entityID = world.entities[index]

  const bs = useComponentValue(ClassBaseStats, index);
  const ev = useComponentValue(ClassEffortValue, index);
  const info = useComponentValue(ClassInfo,index);
  const pokemonIndex = useComponentValue(ClassIndex, index);

  return (
    <div>
      <div>Pokemon Index: {pokemonIndex?.value}</div>
      <LoadPokemonImage classIndex={pokemonIndex?.value} imageType={PokemonImageType.front}/>
      <div>World Index: {index.valueOf()}</div>
      <div>EntityID: {entityID.valueOf()}</div>
      <div>Base Stats: {DisplayStruct(bs)}</div>
      <div>Effort Value: {DisplayStruct(ev)}</div>
      <div>Class Info: {DisplayStruct(info)}</div>
    </div>
  )

}
