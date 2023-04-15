import { ActiveComponent } from "../../useActiveComponent";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useComponentValue, useEntityQuery, useObservableValue } from "@latticexyz/react";
import { getEntitiesWithValue, Has, HasValue, ComponentValue, Type, getComponentValue, EntityID } from "@latticexyz/recs";

import { useKeyboardMovement } from "../../useKeyboardMovement";
import { useMUD } from "../../mud/MUDContext";
import { BigNumber } from "ethers";
import { TimeLeft } from "../Battle/TimeLeft";
import { useTimestamp } from "../../mud/utils/useTimestamp";
import { useMapContext } from "../../mud/utils/MapContext";

export const OFFER_DURATION = 120;

const menuItems = [
  { name: "My Team", value: "myTeam"},
  { name: "Other Team", value: "otherTeam"},
  { name: "$Rescind Offer", value: "rescindOffer"}
]

export const OfferorWait = () => {
  const {setActive, activeComponent} = useMapContext();

  const {
    components: { BattleOfferTimestamp, BattleOffer },
    api: { battleDecline},
    playerEntity,
    playerEntityId
  } = useMUD();
  
  const offereeID = useMemo(()=> {
    return getComponentValue(BattleOffer, playerEntity)?.value
    // return BigNumber.from(hex).toString();
  },[])

  const startTimestamp_hex = useMemo(()=> {
    return getComponentValue(BattleOfferTimestamp, playerEntity)?.value;
  },[])

  const startTimestamp = BigNumber.from(startTimestamp_hex).toNumber()
  const currentTimestamp = useTimestamp();
  const remainingSeconds = Math.max(0, startTimestamp + OFFER_DURATION - currentTimestamp);

  const [selectedItemIndex, setSelectedItemIndex] = useState(0);

  const press_up = () => {
    console.log("test")
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
          return setActive(ActiveComponent.team);
        case "otherTeam":
          return setActive(ActiveComponent.team);
        case "rescindOffer":
          if (remainingSeconds > 0) return;
          await battleDecline(offereeID);
          return console.log("rescindOffer");
      }
    }, [press_up, press_down]);

    const press_b = () => {return;}

    const press_left = () => { return; };
    const press_right = () => { return; };
    const press_start = () => { return;};

  useKeyboardMovement(activeComponent == ActiveComponent.offerorWait, 
    press_up, press_down, press_left, press_right, press_a, press_b, press_start)

  
  return (
    <>
      <TimeLeft startTimestamp={startTimestamp} max_duration={OFFER_DURATION}/>

      <div className="player-console">
        <h1>You have offered another player to battle (to-death). You may rescind this offer to expel him to respawning if he does not respond</h1>
      </div>

      <div className="offeror-wait-menu">
        {menuItems.map((item, index) => (
          <div 
            key={item.value}
            className={`other-player-menu-item ${index === selectedItemIndex ? "selected" : ""} ${index === 2 && remainingSeconds > 0 ? "disabled" :""}`}
          >
            {item.name}
          </div>
        ))}
      </div>
      <style>
      {`
        .offeror-wait-menu {
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
        .disabled {
          color: #999999;
          background-color: #f2f2f2;
          cursor: not-allowed;
        }
      `}
      </style>
    </>
  )
}
