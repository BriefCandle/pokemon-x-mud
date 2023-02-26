import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { uuid } from "@latticexyz/utils";
import {  createEntity, defineComponent, setComponent, withValue } from "@latticexyz/recs";
import { components, RPGStats, RPGMeta } from "./components";

export const CreateHeroClass = (props: any) => {
  const {
    world,
    systems,
    playerEntity,
  } = useMUD();

  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [url, setUrl] = useState('');
  const [others, setOthers] = useState('');

  const [MAXHLTH, setMAXHLTH] = useState(0);
  const [DMG, setDMG] = useState(0);
  const [SPD, setSPD] = useState(0);
  const [PRT, setPRT] = useState(0);
  const [CRT, setCRT] = useState(0);
  const [ACR, setACR] = useState(0);
  const [DDG, setDDG] = useState(0);
  const [DRN, setDRN] = useState(0);

  const createNewHeroClass = (event: any) => {
    event.preventDefault();
    systems["system.CreateHeroClass"].executeTyped(
      {MAXHLTH: MAXHLTH, DMG:DMG, SPD:SPD, PRT:PRT, CRT:CRT, ACR:ACR, DDG:DDG, DRN:DRN},
      {name: name, description:description, url:url, others:others}
    )}

  return (
    <div style={{ display: 'flex', flexDirection: 'column', border: '1px solid black',
    padding: '10px' }}>
      <span>Create New Hero Class</span>
      <form onSubmit={createNewHeroClass}>
        <label>
          Name: <input type="text" value={name}
            onChange={(event) => setName(event.target.value)}/>
        </label>
        <br />
        <label>
          Description: <input type="text" value={description}
            onChange={(event) => setDescription(event.target.value)}/>
        </label>
        <br />
        <label>
          Url: <input type="text" value={url}
            onChange={(event) => setUrl(event.target.value)}/>
        </label>
        <br />
        <label>
          Others: <input type="text" value={others}
            onChange={(event) => setOthers(event.target.value)}/>
        </label>
        <br />


        <label>
        MAXHLTH: <input type="number" value={MAXHLTH}
            onChange={(event) => setMAXHLTH(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        DMG: <input type="number" value={DMG}
            onChange={(event) => setDMG(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        SPD: <input type="number" value={SPD}
            onChange={(event) => setSPD(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        PRT: <input type="number" value={PRT}
            onChange={(event) => setPRT(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        CRT: <input type="number" value={CRT}
            onChange={(event) => setCRT(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        ACR: <input type="number" value={ACR}
            onChange={(event) => setACR(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        DDG: <input type="number" value={DDG}
            onChange={(event) => setDDG(event.target.valueAsNumber)}/>
        </label>
        <br />

        <label>
        DRN: <input type="number" value={DRN}
            onChange={(event) => setDRN(event.target.valueAsNumber)}/>
        </label>
        <br />

        <button type="submit">Create</button>
      </form>
    </div>
  )
}