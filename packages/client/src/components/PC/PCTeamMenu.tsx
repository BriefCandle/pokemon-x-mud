import { ActiveComponent } from "../../useActiveComponent";
import { useCallback, useEffect, useState } from "react";
import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useMUD } from "../../mud/MUDContext";

const PCTeamMenuItems = [
  { name: "Detail", value: "detail"},
  { name: "Deposit", value: "deposit"},
  { name: "Back", value: "back"}
]

export const PCTeamMenu = (props: {setActive: any, activeComponent: any, pokemonIDs: string[], index: number, pc_coord: {x:number,y:number} }) => {
  const {setActive, activeComponent, pokemonIDs, index, pc_coord} = props;

  const { api: {assembelTeam} } = useMUD();

  console.log("pc_coord",pc_coord)


  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_up = () => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1
    )
  }

  const press_down = () => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === PCTeamMenuItems.length - 1 ? selectedItemIndex : selectedItemIndex + 1
    )
  }

  const press_a = useCallback(() => {
      const item = PCTeamMenuItems[selectedItemIndex];
      switch (item.value) {
        case "detail":
          console.log("display detail")
          return; //setActive(ActiveComponent.teamPokemon);
        case "deposit":
          pokemonIDs[index] = "0x00";
          assembelTeam(pokemonIDs, pc_coord);
          return setActive(ActiveComponent.pcOwned);
        case "back":
          return setActive(ActiveComponent.pcTeam);
  
      }
    }, [press_up, press_down]);

    const press_b = () => {
      setActive(ActiveComponent.pcTeam);
    }

    const press_left = () => { return; };
    const press_right = () => { return; };
    const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.pcTeamMenu, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  
  return (
    <>
      <div className="pc-team-menu">
        {PCTeamMenuItems.map((item, index) => (
          <div 
            key={item.value}
            className={`menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            {item.name}
          </div>
        ))}
      </div>
      <style>
      {`
        .pc-team-menu {
          display: flex;
          flex-direction: column;
          bottom: 0;
          right: 0;
          background-color: white;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
          position: absolute; /* Add this to allow z-index */
          z-index: 30; /* Add this to set the z-index */
        }
        
        .menu-item {
          display: flex;
          justify-content: center;
          align-items: center;
          font-family: "Press Start 2P", sans-serif;
          font-size: 16px;
          color: black;
          padding: 8px;
          margin: 4px; /* Update this to have smaller margins */
          border-radius: 12px;
          box-shadow: 0 2px 2px rgba(0, 0, 0, 0.25);
          cursor: pointer;
          text-shadow: 0 1px 1px rgba(0, 0, 0, 0.25); /* Add text shadow for effect */
        }
        
        .selected {
          color: #ffd700;
          background-color: #585858;
        }
      `}
      </style>
    </>
  )
}
