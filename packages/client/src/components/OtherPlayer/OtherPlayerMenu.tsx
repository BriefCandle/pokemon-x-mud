import { ActiveComponent } from "../../useActiveComponent";
import { useCallback, useEffect, useState } from "react";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { getEntitiesWithValue, Has, HasValue, ComponentValue, Type } from "@latticexyz/recs";

import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useMUD } from "../../mud/MUDContext";
import { PrintText } from "../../mud/utils/PrintText";
import { BigNumber } from "ethers";
import { useMapContext } from "../../mud/utils/MapContext";

const menuItems = [
  { name: "Other Team", value: "teamInfo"},
  { name: "$Offer to Battle", value: "offerToBattle"},
  { name: "Watch Battle", value: "watchBattle"},
  { name: "Back", value: "back"}
]

export const OtherPlayerMenu = () => {
  const {setActive, activeComponent, thatPlayerIndex, setThatPlayerIndex} = useMapContext();

  const {
    world,
    api: { battleOffer },
  } = useMUD();

  const thatPlayerID = world.entities[thatPlayerIndex];
  // const thatPlayerID = BigNumber.from(thatPlayerID_hex).toString();

  const [selectedItemIndex, setSelectedItemIndex] = useState(0);
  const [isBusy, setIsBusy] = useState(false);

  const press_up = () => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === 0 ? selectedItemIndex : selectedItemIndex - 1
    )
  }

  const press_down = () => {
    setSelectedItemIndex((selectedItemIndex)=> 
      selectedItemIndex === menuItems.length - 1 ? selectedItemIndex : selectedItemIndex + 1
    )
  }

  const press_a = useCallback(async () => {
      const item = menuItems[selectedItemIndex];
      switch (item.value) {
        case "teamInfo":
          
          setThatPlayerIndex(thatPlayerIndex);
          return setActive(ActiveComponent.team);
        case "offerToBattle":
          setIsBusy(true)
          await battleOffer(thatPlayerID);
          return //setIsBusy(false)
        case "watchBattle":
          return console.log("watch battle");
        case "back":
          return setActive(ActiveComponent.map);
  
      }
    }, [press_up, press_down]);

    const press_b = () => {
      setActive(ActiveComponent.map);
    }

    const press_left = () => { return; };
    const press_right = () => { return; };
    const press_start = () => { setActive(ActiveComponent.map);};

  useKeyboardMovement(activeComponent == ActiveComponent.otherPlayerMenu, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  
  return (
    <>
    { isBusy ?    
      <div className="player-console">
        <h1 style={{color: "black"}}>waiting tx to complete</h1>;
        {/* <PrintText text={"waiting tx to complete"} delay={10}/> */}
      </div> 
      :
      <div className="other-player-menu">
        {menuItems.map((item, index) => (
          <div 
            key={item.value}
            className={`other-player-menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            {item.name}
          </div>
        ))}
      </div>}
      <style>
      {`
        .other-player-menu {
          display: flex;
          flex-direction: column;
          background-color: white;
          border: 4px solid #585858;
          padding: 8px;
          border-radius: 12px;
          box-shadow: 0 4px 4px rgba(0, 0, 0, 0.25);
          position: absolute; /* Add this to allow z-index */
          bottom: 100px;
          right:0;
          z-index: 10; /* Add this to set the z-index */
        }
        
        .other-player-menu-item {
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
