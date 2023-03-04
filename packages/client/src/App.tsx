import { SyncState } from "@latticexyz/network";
import { useComponentValue } from "@latticexyz/react";
import { GameBoard } from "./GameBoard";
import { useMUD } from "./mud/MUDContext";
import { CreateParcel } from "./CreateParcel";
import { useState } from 'react';

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

  const [showComponent, setShowComponent] = useState(false);

  function handleClick() {
    setShowComponent(!showComponent);
  }

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      {loadingState.state !== SyncState.LIVE ? (
        <div>
          {loadingState.msg} ({Math.floor(loadingState.percentage)}%)
        </div>
      ) : (
        <div>
          {!showComponent && <GameBoard />}
          <button className={"fixed left-0 bottom-0 flex items-center justify-center gap-2 m-4 text-sm p-2 rounded leading-none opacity-50 hover:opacity-100"}
          onClick={handleClick}>{showComponent? "Go Back": "Edit Parcel"}</button>
          {showComponent && <CreateParcel />}
      </div>
      )}
    </div>
  );
};
