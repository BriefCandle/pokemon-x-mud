import { useMUD } from "../MUDContext";
import { EntityID, EntityIndex, getComponentValue, World } from "@latticexyz/recs";

export interface PokemonBasicInfo {
  level: number;
  hp: number;
  classIndex: number;
  // name: string;
  maxHP: number;
}

export const getMaxHP = (pokemonIndex: EntityIndex) => {
  const {world, components: { ClassEffortValue, ClassBaseStats  } } = useMUD();

  const classID = getClassID(pokemonIndex)?.value as number;
  const classIndex = world.entityToIndex.get(classID);
  const baseStats_HP = getComponentValue(ClassBaseStats, classIndex)?.HP as number;
  const evStats_HP = getComponentValue(ClassEffortValue, classIndex)?.HP as number;
  const level = getLevel(pokemonIndex)?.value as number;
  return Math.floor((2 * baseStats_HP + evStats_HP/4) * level / 100 + level + 10);
  // return getComponentValue(PokemonHP, pokemonIndex);
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

export const getClassIndex = (pokemonIndex: EntityIndex) => {
  const { world, components: { ClassIndex } } = useMUD();

  const classID = getClassID(pokemonIndex)?.value;

  const classID_Index = world.entityToIndex.get(classID as EntityID)
  return getComponentValue(ClassIndex, classID_Index);
}

export const getMoves = (pokemonIndex: EntityIndex) => {
  const {components: {PokemonMoves}} = useMUD();

  return getComponentValue(PokemonMoves, pokemonIndex)?.value;
}

export const moveIDToName = (moveID: EntityID) => {
  const {world, components: {MoveName}} = useMUD();
  
  return getComponentValue(MoveName, world.entityToIndex.get(moveID))?.value;
}

export const pokemonIndexToMoveNames = (pokemonIndex: EntityIndex) => {
  const moveIDs = getMoves(pokemonIndex) as EntityID[];
  
  return moveIDs.map((moveID)=>{return moveIDToName(moveID)} )
}

export const getTeamPokemonInfo = (pokemonIndex: EntityIndex): PokemonBasicInfo => {
  const HP = getHP(pokemonIndex)?.value as number;
  const level = getLevel(pokemonIndex)?.value as number;
  const classIndex = getClassIndex(pokemonIndex)?.value as number;
  const maxHP = getMaxHP(pokemonIndex);
  const pokemonInfo: PokemonBasicInfo = {level: level, hp: HP, classIndex: classIndex, maxHP: maxHP};
  return pokemonInfo;
}
