import { useEffect } from "react";
import { useMUD } from "./mud/MUDContext";

export const useKeyboardMovement = () => {
  const {
    api: { crawlBy },
  } = useMUD();

  useEffect(() => {
    const listener = (e: KeyboardEvent) => {
      console.log(e.key)
      if (e.key === "w") {
        crawlBy(0, -1);
      }
      if (e.key === "s") {
        crawlBy(0, 1);
      }
      if (e.key === "a") {
        crawlBy(-1, 0);
      }
      if (e.key === "d") {
        crawlBy(1, 0);
      }
    };
    window.addEventListener("keydown", listener);
    return () => window.removeEventListener("keydown", listener);
  }, [crawlBy]);
}