import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "../../mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";

export const DisplayStruct = (struct:any) => {
  const entries = Object.entries(struct);
  return (
    <div>
      {entries.map(([key, value])=> {       
        return  <>{key}:{value} &nbsp;</>
      })}
    </div>
  )
}

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



  return (
    <div> 
      <br />
      {moveIDs && Array.from(moveIDs).map((id, index)=>(
        <div key={index} style={{ display: 'flex', flexDirection: 'column'}}>
          <div>Move Name: {moveNames[index]}</div>
          <div>Move ID: {moveIDs[index]}</div>
          <div>Move Index: {moveIndexes[index]}</div>
          <div>Move Info: {DisplayStruct(moveInfo[index])}</div>
          {/* <DisplayStruct struct={moveInfo[index]} /> */}
          {/* <DisplayStruct struct={moveEffect[index]} /> */}
          <div>Move Effect: {DisplayStruct(moveEffect[index])}</div>
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