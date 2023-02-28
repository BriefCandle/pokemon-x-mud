import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";



export const PokemonMoves = (props:any) => {
  const {
    components: { MoveEffect, MoveInfo, MoveName, MoveLevelPokemon},
    world,
  } = useMUD();

  const pokemonIndex = props.index;
  const moveIDs = useComponentValue(MoveLevelPokemon, pokemonIndex)?.value as any[];
  const moveIndexes = moveIDs?.map(id => {return world.getEntityIndexStrict(id)});
  const moveNames = moveIndexes?.map(index => {return useComponentValue(MoveName, index)?.value});
  const moveInfo = moveIndexes?.map(index => {return useComponentValue(MoveInfo, index)});
  const moveEffect = moveIndexes?.map(index => {return useComponentValue(MoveEffect, index)});

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
      <br />
      {moveIDs && Array.from(moveIDs).map((id, index)=>(
        <div key={index} style={{ display: 'flex', flexDirection: 'column'}}>
          <div>Move Name: {moveNames[index]}</div>
          <div>Move ID: {moveIDs[index]}</div>
          <div>Move Index: {moveIndexes[index]}</div>
          <div>Move Info: {displayStruct(moveInfo[index])}</div>
          <div>Move Effect: {displayStruct(moveEffect[index])}</div>
          <br />
        </div>
      ))}
      {/* { moveIDs && 
      <div>{moveIDs}</div> &&
      <div>{moveNames}</div>
      } */}
    </div>
  )
}