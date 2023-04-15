import { setupMUDNetwork } from "@latticexyz/std-client";
import { SystemTypes } from "contracts/types/SystemTypes";
import { config } from "./config";
import { components, clientComponents } from "./components";
import { world } from "./world";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import { EntityID, getComponentValue, Has } from "@latticexyz/recs";
import { createFaucetService } from "@latticexyz/network";
import { ethers } from "ethers";
import { GodID as singletonEntityId } from "@latticexyz/network";
import { uuid } from "@latticexyz/utils";
import { BattleActionType } from "../enum/battleActionType";


export type SetupResult = Awaited<ReturnType<typeof setup>>;

export const setup = async () => {
  console.info(`Booting with network config:`, config);

  const result = await setupMUDNetwork<typeof components, SystemTypes>(
    config,
    world,
    components,
    SystemAbis,
    {
      fetchSystemCalls: true,
    }
  );

  result.startSync();

  // For LoadingState updates
  const singletonEntity = world.registerEntity({ id: singletonEntityId });

  // Register player entity
  const address = result.network.connectedAddress.get();
  console.log(address)
  if (!address) throw new Error("Not connected");

  const playerEntityId = address as EntityID;
  const playerEntity =  world.registerEntity({ id: playerEntityId });
  console.log(playerEntity);

  // Request drip from faucet
  if (!config.devMode && config.faucetServiceUrl) {
    const faucet = createFaucetService(config.faucetServiceUrl);
    console.info("[Dev Faucet]: Player Address -> ", address);

    const requestDrip = async () => {
      const balance = await result.network.signer.get()?.getBalance();
      console.info(`[Dev Faucet]: Player Balance -> ${balance}`);
      const playerIsBroke = balance?.lte(ethers.utils.parseEther("1"));
      console.info(`[Dev Faucet]: Player is broke -> ${playerIsBroke}`);
      if (playerIsBroke) {
        console.info("[Dev Faucet]: Dripping funds to player");
        // Double drip
        address &&
          (await faucet?.dripDev({ address })) &&
          (await faucet?.dripDev({ address }));
      }
    };
    requestDrip();
    // Request a drip every 20 seconds
    setInterval(requestDrip, 20000);
  }

  // Add support for optimistic rendering
  const componentsWithOverrides = {
    // ClassHeroStats: overridableComponent(components.ClassHeroStats),
    // Player: overridableComponent(components.Player),
  };

  // ---------------- api ---------------------------------------

  const crawlTo = async (x: number, y: number) => {
    const positionId = uuid();
    components.Position.addOverride(positionId, {
      entity: playerEntity,
      value: { x, y },
    });
    try {
      const tx = await result.systems["system.Crawl"].executeTyped({ x, y });
      await tx.wait();
    } finally {
      components.Position.removeOverride(positionId);
    }
  };

  const crawlBy = async (deltaX: number, deltaY: number) => {
    const playerPosition = getComponentValue(components.Position, playerEntity);
    if (!playerPosition) {
      console.warn("csetup: annot moveBy without a player position, not yet spawned?");
      return;
    }
    await crawlTo(playerPosition.x + deltaX, playerPosition.y + deltaY);
  };

  const spawnPlayer = async (pokemonIndex: number) => {
    // const pokemonIndex = 1;
    const canSpawn = getComponentValue(components.Player, playerEntity)?.value !== true;
    if (!canSpawn) {
      throw new Error("setup: already joined game");
    }
    try {
      const tx = await result.systems["system.SpawnPlayer"].executeTyped(pokemonIndex);
      await tx.wait();
    } finally {
      console.log("setup: player spawn")
      // components.Position.removeOverride(positionId);
    }
  }

  const respawn = async () => {
    try {
      const bytes = new Uint8Array(0)
      const tx = await result.systems["system.Respawn"].execute(bytes)
      await tx.wait()
    } finally {
      console.log("setup: player respawn")
    }
  }

  const logout = async () => {
    try {
      const bytes = new Uint8Array(0);
      const tx = await result.systems["system.Logout"].execute(bytes)
      await tx.wait()
    } finally {
      console.log("setup: player logout")
    }
  }

  const assembleOldTeam = async (pokemonIDs: string[]) => {
    try {
      const tx = await result.systems["system.AssembleOldTeam"].executeTyped(pokemonIDs);
      await tx.wait();
    } finally {
      console.log("setup: old team reassembled")
    }
  }

  const assembelTeam = async (pokemonIDs: string[], pc_coord: {x:number,y:number}) => {
    try {
      const tx = await result.systems["system.AssembleTeam"].executeTyped(pokemonIDs, pc_coord);
      await tx.wait();
    } finally {
      console.log("setup: team reassembled")
    }
  }

  const restoreTeamHP = async (nurse_coord: {x:number, y:number}) => {
    try {
      const tx = await result.systems["system.RestoreTeamHP"].executeTyped(nurse_coord);
      await tx.wait();
    } finally {
      console.log("setup: teamHP restored");
    }
  }
  
  const battle = async (battleID: string, targetID: string, action: BattleActionType) => {
    try {
      const tx = await result.systems["system.Battle"].executeTyped(battleID, targetID, action);
      await tx.wait();
    } finally {
      console.log("setup: battle action submitted")
    }
  }

  const battleOffer = async (offereeID: string) => {
    try {
      const tx = await result.systems["system.BattleOffer"].executeTyped(offereeID);
      await tx.wait();
    } finally {
      console.log("setup: battle offer submitted")
    }
  }

  const battleAccept = async () => {
    try {
      const bytes = new Uint8Array(0)
      const tx = await result.systems["system.BattleAccept"].execute(bytes);
      await tx.wait();
    } finally {
      console.log("setup: battle accept submitted")
    }
  }

  const battleDecline = async (offereeID: string) => {
    try {
      const tx = await result.systems["system.BattleDecline"].executeTyped(offereeID);
      await tx.wait();
    } finally {
      console.log("setup: battle decline submitted")
    }
  }





  // spawnPlayer();

  return {
    ...result,
    world,
    singletonEntityId,
    singletonEntity,
    playerEntityId,
    playerEntity,
    components: {
      ...result.components,
      ...componentsWithOverrides,
      ...clientComponents,
    },
    api: {
      crawlTo,
      crawlBy,
      spawnPlayer,
      respawn,
      logout,
      assembleOldTeam,
      assembelTeam,
      restoreTeamHP,
      battle,
      battleOffer,
      battleAccept,
      battleDecline
    },
  };
};
