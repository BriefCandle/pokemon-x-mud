import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { GameBoard } from "./GameBoard";
import { useMUD } from "./mud/MUDContext";
import { CreateParcel } from "./CreateParcel";
import { useState } from 'react';
import { PokemonClasses } from "./components/PokemonClass/PokemonClasses";

export const App = () => {
  const {
    components: { LoadingState },
    singletonEntity,
  } = useMUD();
  
  const loadingState = useComponentValue(
    LoadingState,
    singletonEntity
  ) ?? {
    state: SyncState.CONNECTING,
    msg: "Connecting",
    percentage: 0,
  };

  const [showComponent, setShowComponent] = useState(0);

  function handleClick1() {
    setShowComponent(showComponent==1?0:1);
  }

  function handleClick2() {
    setShowComponent(showComponent==2?0:2);
  }

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : (
        <div>
          {showComponent==0 && <GameBoard />}
          <button className={"fixed left-0 bottom-0 flex items-center justify-center gap-2 m-4 text-sm p-2 rounded"}
          onClick={handleClick1}>{showComponent==1? "Go Back": "Edit Parcel"}</button>
          {showComponent==1 && <CreateParcel />}
          <button className={"fixed left-0 top-0 flex items-center justify-center gap-2 m-4 text-sm p-2 rounded"}
          onClick={handleClick2}>{showComponent==2 ? "Go Back": "View Pokemon Class"}</button>
          {showComponent==2 && <PokemonClasses />}
        </div>
      )}
    </div>
  );
};
