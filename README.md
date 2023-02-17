# roguelike-mud

# Overview
Generally speaking, an RPG consists of players collecting and managing in-game elements (characters, equipment, buffs, etc.). Players’ game goal is realized through battling, in which players optimize strategies to properly stack the stats of their in-game elements so as to interact with the game. A feedback loop is established through rewarding in-game tokens (exp, crystal, and etc.) after battling or completing other in-game activities, which can then be used to upgrade in-game elements, i.e., improving their stats. Therefore, an RPG concerns with two main mechanisms: 1) categorization of in-game elements, and 2) interactions among in-game elements (battling, upgrading, and etc.)

With these two concerns in mind, I use MUD's ECS (entity-component-system) model to realize two features, which I believe to be vital to an on-chain RPG:
1) Separation between instances and classes of RPG characters and ownable entities.
2) Turn-based battle with buff/debuff effect on RPG characters’ stats.

# Class-Instance Entities
As to class-instance entities, there are some general principles:
1) ownership indicates an owner’s sole right to dispose of entities as he sees fit;
2) ownable entities are created through the class objects of which the project itself takes control;
3) conceptual entities cannot be owned, and therefore have no instances. 
4) Some conceptual entities are NOT subject to players’ choices/will, but subject to game randomness engine (like a Beherit in Berserk :D)

# Authorization-Right
As to authorization on entity, there are various types of authorization players or contracts may have over entity, such as ownership, commanding, 

For example, to enter into a dungeon, a player needs to assemble a team from heroes he owns. Breaking it down, ownership changes hands from the player to the team component contract when a team is formed. Rights associated with ownership is no longer applicable to the player. In other words, the player can no longer transfer, authorize transfer, or call any other external function in an ERC721 contract on individual heroes in a team. 

The player now owns the team he created. There are then team-specific ownership rights the player can exercise. For instance, the player can exercise the team dissemble right, which could be stored in a team commander component, and be callable by a dissemble team system. There are also team-specific commanding rights the player can exercise. For instance, the player can order his team to enter into a dungeon, to move around within a dungeon, and to order team members to attack enemies. When a hero dies in a dungeon, the hero is permanently removed from the team, and therefore the player can no longer command it.

The benefit of defining rights and authorization is to allow concepts to be built on each other in a hierachical and parallel order. 
