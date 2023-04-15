import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { ActiveComponent } from "../../useActiveComponent";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { BattleActionType } from "../../enum/battleActionType";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { pokemonIndexToMoveNames, getMoves } from "../../mud/utils/pokemonInstance";

const actionMenuItems = [
  {name: "Move0", value: BattleActionType.Move0},
  {name: "Move1", value: BattleActionType.Move1},
  {name: "Move2", value: BattleActionType.Move2},
  {name: "Move3", value: BattleActionType.Move3},
  {name: "UsePokeball", value: BattleActionType.UsePokeball},
  {name: "Skip", value: BattleActionType.Skip},
  {name: "Escape", value: BattleActionType.Escape}
]

export const BattlePlayerAction = () => {

  const {
    world,
    api: { battle },
    components: { PokemonMoves, MoveName },
  } = useMUD();

  const {battleID, player_turn_pokemon, next_pokemonID, commit, activeComponent, selectedAction, setSelectedAction, setActive, setSelectedTarget, setMessage} = useBattleContext();
  
  // setActive(ActiveComponent.battlePlayerAction)
  const pokemonIndex = world.entityToIndex.get(next_pokemonID)
  const pokemonMoves_ID = getComponentValueStrict(PokemonMoves, pokemonIndex)?.value as EntityID[];
  const pokemonMoves_index: (EntityIndex | undefined) [] = pokemonMoves_ID.map((moveID)=> {
    return world.entityToIndex.get(moveID)
  })
  // const pokemonMoves_name: (string | undefined) [] = pokemonMoves_index.map((moveIndex)=> {
  //   if (moveIndex) return getComponentValueStrict(MoveName, moveIndex).value;
  //   else return undefined;
  // })

  const moveNames = pokemonIndexToMoveNames(world.getEntityIndexStrict(next_pokemonID))
  console.log("player move names: ", moveNames)

  // ----- key input functions -----
  const [selectedItemIndex, setSelectedItemIndex] = useState(0); // redundant but keep the pattern

  const press_left = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1)
  },[])

  const press_right = useCallback(() => {
    setSelectedItemIndex((selectedItemIndex)=> 
    selectedItemIndex === actionMenuItems.length -1 ? selectedItemIndex : selectedItemIndex+1)
  },[])

  const press_a = useCallback(async () => {
    const item = actionMenuItems[selectedItemIndex];
      if (item.value === BattleActionType.Move0 || item.value === BattleActionType.Move1 || 
          item.value === BattleActionType.Move2 || item.value === BattleActionType.Move3 || 
          item.value === BattleActionType.UsePokeball ||  item.value === BattleActionType.Escape) {
        setSelectedAction(item.value);
        // setActive(ActiveComponent.battlePlayerTarget);
        setSelectedTarget(0)
      }
      else if (item.value === BattleActionType.Skip) {
        await battle(battleID, "0x00", BattleActionType.Skip)
      }
      else return
  }, [selectedItemIndex]);

  const press_b = () => { return;}
  const press_up = () => { return; };
  const press_down = () => { return; };
  const press_start = () => { return; };

  useKeyboardMovement(true, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)


  return (
    <>
      <div className="battle-player-action">
        { actionMenuItems.map((item, index) => (
          <div
            key={item.value}
            className={`action-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            {moveNames[index] ? moveNames[index] : item.name}
          </div>)
        )}
      </div>
      <style>
        {`
          .battle-player-action {
            display: flex;
            flex-direction: row;
            justify-content: space-between;
            align-tems: center;
            color: black;
            height: 100px;
            font-size: 12px;
            width: 100%;
          }

          .action-item {
            text-align: center;
          }
        `}
      </style>
    </>
  )

}