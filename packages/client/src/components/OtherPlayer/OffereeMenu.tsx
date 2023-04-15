import { ActiveComponent } from "../../useActiveComponent";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { getEntitiesWithValue, Has, HasValue, ComponentValue, Type, EntityIndex, getComponentValue } from "@latticexyz/recs";

import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useMUD } from "../../mud/MUDContext";
import { TimeLeft } from "../Battle/TimeLeft";
import { BigNumber } from "ethers";
import { useTimestamp } from "../../mud/utils/useTimestamp";
import { OFFER_DURATION } from "./OfferorWait";
import { useMapContext } from "../../mud/utils/MapContext";

const menuItems = [
  { name: "My Team", value: "myTeam"},
  { name: "Other Team", value: "otherTeam"},
  { name: "$Accept Offer", value: "acceptOffer"},
  { name: "$Rescind Offer", value: "rescindOffer"}
]

export const OffereeMenu = () => {
  const {setActive, activeComponent, setThatPlayerIndex} = useMapContext();

  const {
    world,
    components: { BattleOfferTimestamp, BattleOffer, Team },
    api: { battleAccept, battleDecline },
    playerEntity,
    playerEntityId
  } = useMUD();

  const offerorIndex = useEntityQuery([HasValue(BattleOffer, {value: playerEntityId})])[0];

  const startTimestamp_hex = useMemo(()=> {
    return getComponentValue(BattleOfferTimestamp, offerorIndex)?.value;
  },[])

  const startTimestamp = BigNumber.from(startTimestamp_hex).toNumber()

  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

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
        case "myTeam":
          setThatPlayerIndex(playerEntity);
          return setActive(ActiveComponent.team);
        case "otherTeam":
          setThatPlayerIndex(offerorIndex);
          return setActive(ActiveComponent.team);
        case "acceptOffer":
          await battleAccept()
          return ; 
        case "rescindOffer":
          await battleDecline(playerEntityId)
          return;
      }
    }, [press_up, press_down]);

    const press_b = () => { return; };

    const press_left = () => { return; };
    const press_right = () => { return; };
    const press_start = () => { return;};

  useKeyboardMovement(activeComponent == ActiveComponent.offereeMenu, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  
  return (
    <>
      <TimeLeft startTimestamp={startTimestamp} max_duration={OFFER_DURATION}/>

      <div className="player-console">
        <h1>You were offered to battle (to-death). Rescinding the offer results into respawning</h1>
      </div>

      <div className="offeree-menu">
        {menuItems.map((item, index) => (
          <div 
            key={item.value}
            className={`offeree-menu-item ${index === selectedItemIndex ? "selected" : ""}`}
          >
            {item.name}
          </div>
        ))}
      </div>
      <style>
      {`
        .offeree-menu {
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
        
        .offeree-menu-item {
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
