import { useState, useEffect } from 'react';


export const BattleLoadingScreen = ( {onTransitionComplete}) => {
  const [isFlashing, setIsFlashing] = useState(true);
  const [isTransitioning, setIsTransitioning] = useState(false);
  
  useEffect(() => {
    const flashScreen = (count:number) => {
      if (count ===0) {
        setIsFlashing(false);
        setIsTransitioning(true);
        return;
      }
      setIsFlashing((prev) => !prev);
      setTimeout(() => flashScreen(count - 1), 400);
    };
  
    flashScreen(4);
  
    return () => {
      clearTimeout(0);
    };
  }, []);

  const handleTransitionEnd = (e) => {
    if (e.target === e.currentTarget) {
      console.log("handleTransitionEnd");
      onTransitionComplete();
    }
  };

  return (
    <>
    {isFlashing && <div className="flash"></div>}
    {isTransitioning && (<div className="transition" onAnimationEnd={handleTransitionEnd}></div>)}
    
    <style>
    {`
    .flash {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: black;
      z-index: 999;
    }
    
    .transition {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: black;
      z-index: 999;
      animation: transition 1.5s forwards;
    }
    
    @keyframes transition {
      0% {
        transform: scaleX(0);
      }
      100% {
        transform: scaleX(1);
      }
    }
    
    `}
    </style>
    </>

  );
}