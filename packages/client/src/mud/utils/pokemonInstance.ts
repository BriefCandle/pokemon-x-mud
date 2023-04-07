import { useMUD } from "../MUDContext";
import { EntityIndex, getComponentValue, World } from "@latticexyz/recs";

export interface PokemonBasicInfo {
  level: number;
  hp: number;
  classIndex: number;
}

export const getHP = (pokemonIndex: EntityIndex) => {
  const {components: { PokemonHP } } = useMUD();

  return getComponentValue(PokemonHP, pokemonIndex);
}

export const getLevel = (pokemonIndex: EntityIndex) => {
  const { components: { PokemonLevel } } = useMUD();

  return getComponentValue(PokemonLevel, pokemonIndex);
}

export const getClassID = (pokemonIndex: EntityIndex) => {
  const { components: { PokemonClassID } } = useMUD();

  return getComponentValue(PokemonClassID, pokemonIndex);
}

// export const getClassIndex = (pokemonIndex: EntityIndex) => {
//   const { components: { ClassIndex } } = useMUD();

//   const classID = getClassID(pokemonIndex)?.value as number;

//   return getComponentValue(ClassIndex, classID);
// }

export const getTeamPokemonInfo = (pokemonIndex: EntityIndex): PokemonBasicInfo => {
  const HP = getHP(pokemonIndex)?.value as number;
  const level = getLevel(pokemonIndex)?.value as number;
  const classIndex = 1;
  const pokemonInfo: PokemonBasicInfo = {level: level, hp: HP, classIndex: classIndex};
  return pokemonInfo;
}