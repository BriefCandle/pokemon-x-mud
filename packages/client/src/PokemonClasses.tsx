import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";
import { PokemonMoves } from "./PokemonMoves";
import { PokemonClass } from "./PokemonClass";



export const PokemonClasses = () => {
  const {
    components: { BaseStats},
    world,
    systems,
    playerEntity,
  } = useMUD();

    console.log(world)
  // const heroIDs = ClassHeroStats.entities()
  const pokemonWorldIndexes = getComponentEntities(BaseStats);

  return (
    <div>
      <span>Pokemon Class</span>
      <div style={{ display: 'flex', flexDirection: 'row' }}>
      {/* {Array.from(pokemonWorldIndexes).map((worldIndex, index) => {
        <PokemonClass indexes={""}/>
      })
      } */}
      {Array.from(pokemonWorldIndexes).map((worldIndex, index) => (
        <div key={index} style={{ display: 'flex', flexDirection: 'column', border: '1px solid black', padding: '10px' }}>
          <PokemonClass index={worldIndex} />
          <PokemonMoves index={worldIndex}/>
        </div>
      ))}
      </div>
    </div>
  );
};

// const entityID = world.entities[worldIndex]
// const bs = useComponentValue(BaseStats, worldIndex);
// const ev = useComponentValue(EffortValue, worldIndex);
// const cr = useComponentValue(CatchRate, worldIndex);
// const lr = useComponentValue(LevelRate, worldIndex);
// const i = useComponentValue(PokemonIndex, worldIndex);
// const type1 = useComponentValue(PokemonType1, worldIndex);
// const type2 = useComponentValue(PokemonType2, worldIndex);
// const test = useComponentValue(MoveLevelPokemon, worldIndex);
// console.log(test)
// // <DisplayPokemonMove moveIDs={test} />
// // console.log(world.entityToIndex.get(test?.value[1]))
// return (
//   <div key={index} style={{ display: 'flex', flexDirection: 'column', border: '1px solid black',
//   padding: '10px' }}>
//     {/* <img src={meta?.url as string} alt="" /> */}
//     <div>Pokmon world Index: {worldIndex.valueOf()}</div>
//     <div>EntityID: {entityID.valueOf()}</div>
//     <div>Pokemon Index: {i?.value}</div>
//     <div>Base Stats (HP): {bs?.HP}</div>
//     <div>Effort Value (HP): {ev?.HP}</div>
//     <div>Catch Rate: {cr?.value}</div>
//     <div>Level Rate: {lr?.value}</div>
//     <div>Type 1: {type1?.value}</div>
//     <div>Type 2: {type2?.value}</div>
//     <DisplayPokemonMove moveIDs={test}/>
//   </div>
// );