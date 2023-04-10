import { useEffect, useState } from "react";

export function useTimestamp() {

  const [currentTimestamp, setCurrentTimestamp] = useState(Date.now() * 0.001);
  
   useEffect(() => {
    const intervalId = setInterval(() => {
      setCurrentTimestamp(Date.now() * 0.001);
    }, 100);
    
    return () => clearInterval(intervalId);
  }, []); 

  return currentTimestamp;
}