import { useMUD } from "./mud/MUDContext";
import { useState, useEffect } from "react";
import { components, RPGStats, RPGMeta } from "./components";

export const EditHeroClass = (props: any) => {
  const {
    systems,
  } = useMUD();

  const [name, setName] = useState(props.meta.name);
  const [description, setDescription] = useState(props.meta.description);
  const [url, setUrl] = useState(props.meta.url);
  const [others, setOthers] = useState(props.meta.others);

  const [MAXHLTH, setMAXHLTH] = useState(props.stats.MAXHLTH);
  const [DMG, setDMG] = useState(props.stats.DMG);
  const [SPD, setSPD] = useState(props.stats.SPD);
  const [PRT, setPRT] = useState(props.stats.PRT);
  const [CRT, setCRT] = useState(props.stats.CRT);
  const [ACR, setACR] = useState(props.stats.ACR);
  const [DDG, setDDG] = useState(props.stats.DDG);
  const [DRN, setDRN] = useState(props.stats.DRN);

  // if (props.stats !== undefined) {
  //   setName(props.meta.name);setDescription(props.meta.description);
  //   setUrl(props.meta.url);setOthers(props.meta.others);
  //   setMAXHLTH(props.stats.MAXHLTH);setDMG(props.stats.DMG);setSPD(props.stats.SPD);
  //   setPRT(props.stats.PRT);setCRT(props.stats.CRT);setACR(props.stats.ACR);
  //   setDDG(props.stats.DDG);setDRN(props.stats.DRN)
  // }

  const EditHeroClass = (event: any) => {
    event.preventDefault();
    console.log(props.entityID)
    systems["system.EditHeroClass"].executeTyped(
      props.entityID,
      {MAXHLTH: MAXHLTH, DMG:DMG, SPD:SPD, PRT:PRT, CRT:CRT, ACR:ACR, DDG:DDG, DRN:DRN},
      {name: name, description:description, url:url, others:others}
    )
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', border: '1px solid black',
    padding: '10px' }}>
      <span>Edit Hero Class</span>
      <form onSubmit={EditHeroClass}>
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

        <button type="submit">Submit Change</button>
      </form>
    </div>
  )
}