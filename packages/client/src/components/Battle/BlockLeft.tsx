import { useEffect, useState } from "react";
import { useMUD } from "../../mud/MUDContext";
import { useBattleContext } from "../../mud/utils/BattleContext";
import { useBlockNumber } from "../../mud/utils/useBlockNumber";

const cx = 30;
const cy = 30;
const r = 15;

const max_height = 255;
const min_height = 5;

export const BlockLeft = (props: {startBlock: number, duration: number}) => {
  const {startBlock, duration} = props;

  // const {commit} = useBattleContext();

  const blockNumber = useBlockNumber();

  if (!blockNumber) return null;

  const remainingBlocks = Math.max(0, startBlock + duration - blockNumber);
  const perimeter = 2 * Math.PI * r; // perimeter of the circle, assuming a radius of 50 pixels
  const progress = (duration - remainingBlocks) / duration;
  const remainingPerimeter = perimeter * (1 - progress);


  return (
    <svg width="100" height="100" style={{ position: "absolute", top: 10, left: 10 }}>
      <circle cx={cx} cy={cy} r={r} stroke="#ccc" strokeWidth="2" fill="none" />
      <circle cx={cx} cy={cy} r={r} stroke="green" strokeWidth="3" strokeDasharray={`${remainingPerimeter} ${perimeter}`} transform={`rotate(-90 ${cx} ${cy})`} fill="none" />
      <text x={cx} y={cy} textAnchor="middle" alignmentBaseline="middle" fontSize="10">{Math.round(remainingBlocks)}</text>
    </svg>
  );
}