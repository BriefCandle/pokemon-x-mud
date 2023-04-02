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
    console.log(playerEntity)
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
      console.warn("cannot moveBy without a player position, not yet spawned?");
      return;
    }
    await crawlTo(playerPosition.x + deltaX, playerPosition.y + deltaY);
  };

  const spawnPlayer = async () => {
    const pokemonIndex = 1;
    const canSpawn = getComponentValue(components.Player, playerEntity)?.value !== true;
    if (!canSpawn) {
      throw new Error("already joined game");
    }
    try {
      const tx = await result.systems["system.SpawnPlayer"].executeTyped(pokemonIndex);
      await tx.wait();
    } finally {
      // components.Position.removeOverride(positionId);
    }
  }

  spawnPlayer();

  console.log("test")

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
    },
  };
};
