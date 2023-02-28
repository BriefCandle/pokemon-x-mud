import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { getComponentEntities } from "@latticexyz/recs";



export const PokemonInstance = () => { 
  const {
    components: { PokemonInstance },
    world
  } = useMUD();


}