import { LoadPokemonImage, PokemonImageType } from "./loadPokemonImage";
import { useCallback } from "react";
import { PokemonBasicInfo, getTeamPokemonInfo } from "../../mud/utils/pokemonInstance";



export const PokemonBasicInfoBar = (prop: {basicInfo: PokemonBasicInfo | undefined}) => {
  const basicInfo = prop.basicInfo;
  if (basicInfo === undefined) return null;

  const { level, hp, classIndex, maxHP } = basicInfo;


  return (
    <>
    <div className="pokemon-basic-info">
      <div className="pokemon-icon">
        <LoadPokemonImage classIndex={classIndex} imageType={PokemonImageType.icon}/>
      </div>
      <div className="pokemon-info">
        <div className="pokemon-name">Index {classIndex}</div>
        <div className="pokemon-level">Level: {level}</div>
      </div>
      <div className="pokemon-hp-info">
        <div className="pokemon-health-bar">
          <div className="pokemon-health-bar-inner" style={{ width: `${(hp / maxHP) * 100}%` }}></div>
        </div>
        <div className="pokemon-hp">
          HP: {hp}/{maxHP}
        </div>

      </div>
    </div>

    <style>
      {`
      .pokemon-basic-info {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
      }
      
      .pokemon-icon {
        // flex-shrink: 0;
      }
      
      .pokemon-info {
        display: flex;
        flex-direction: column;
        margin-left: 8px;
      }
      
      .pokemon-name,
      .pokemon-level {
        margin-bottom: 4px;
      }
      
      .pokemon-hp-info {
        flex-grow: 0.5;
        display: flex;
        flex-direction: column;
        align-items: flex-end;
      }
      
      .pokemon-hp {
        margin-bottom: 4px;
      }
      
      .pokemon-health-bar {
        max-width: 150px;
        width: 100%;
        height: 12px;
        background-color: #e0e0e0;
        border-radius: 6px;
        overflow: hidden;
      }
      
      .pokemon-health-bar-inner {
        height: 100%;
        background-color: #00cc00;
      }
      
      `}
    </style>
    </>
  );
}