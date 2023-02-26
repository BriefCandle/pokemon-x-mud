import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { CreateHeroClass } from "./CreateHeroClass";
import { EditHeroClass } from "./EditHeroClass";
import { getComponentEntities, EntityIndex } from "@latticexyz/recs";



export const HeroClass = () => {
  const {
    components: { ClassHeroStats, ClassHeroMeta },
    world,
    systems,
    playerEntity,
  } = useMUD();

  // const heroIDs = ClassHeroStats.entities()
  const heroIndexes = getComponentEntities(ClassHeroStats);
  
  // useEffect(() => {
  //   const subscription = ClassHeroStats.update$.subscribe(({value})=>{console.log(value)});
  //   return () => subscription.unsubscribe();
  // }, [])
  // const classHeroStats = useComponentValue(ClassHeroStats, playerEntity);

  // components.ClassHeroMeta.entities()
  
  const [toEdit, setToEdit] = useState(-1);

  const handleEdit = (index: number) =>{
    setToEdit(index);
  }

  return (
    <div>
      <span>Hero Classes</span>
      <div style={{ display: 'flex', flexDirection: 'row' }}>
      { 
        Array.from(heroIndexes, (heroIndex, index) => {
          const entityID = world.entities[heroIndex]
          const stats = useComponentValue(ClassHeroStats, heroIndex);
          const meta = useComponentValue(ClassHeroMeta, heroIndex);
          return (
            <div key={index} style={{ display: 'flex', flexDirection: 'column', border: '1px solid black',
            padding: '10px' }}>
              <img src={meta?.url as string} alt="" />
              <div>HeroID: {entityID}</div>
              <div>Name: {meta?.name}</div>
              <div>Description: {meta?.description}</div>
              <div>MAXHLTH: {stats?.MAXHLTH}</div>
              <div>DMG: {stats?.DMG}</div>
              <div>SPD: {stats?.SPD}</div>
              <button onClick={()=>{handleEdit(index)}}>Edit</button>
              {toEdit === index && <EditHeroClass entityID={entityID} stats={stats} meta={meta}/>}
            </div>
          );
        })
      }
      </div>
      <CreateHeroClass />
    </div>
  );
};