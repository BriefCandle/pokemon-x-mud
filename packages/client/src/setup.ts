import { setupMUDNetwork } from "@latticexyz/std-client";
import { SystemTypes } from "contracts/types/SystemTypes";
import { config } from "./mud/config";
import { components, clientComponents } from "./components";
import { world } from "./mud/world";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import { EntityID, getComponentValue,  } from "@latticexyz/recs";
import { GodID as singletonEntityId } from "@latticexyz/network";
import { uuid } from "@latticexyz/utils";


export type SetupResult = Awaited<ReturnType<typeof setup>>;

export const setup = async () => {
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
  if (!address) throw new Error("Not connected");

  const playerEntityId = address as EntityID;
  const playerEntity = world.registerEntity({ id: playerEntityId });

  // Add support for optimistic rendering
  const componentsWithOverrides = {
    // ClassHeroStats: overridableComponent(components.ClassHeroStats),
    // Player: overridableComponent(components.Player),
  };

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
      console.warn("cannot moveBy without a player position, not yet spawned?");
      return;
    }
    await crawlTo(playerPosition.x + deltaX, playerPosition.y + deltaY);
  };

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
    },
  };
};
