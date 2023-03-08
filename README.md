# Roguelike X MUD

# Overview
An RPG is a game genre involving players strategically collecting and managing in-game elements (characters, equipment, skills, buffs, etc.). Players’ game goal is realized through "battling", in which players properly "stack" the stats of their in-game elements so as to achieve an optimized battling outcome. A feedback loop is then established by rewarding in-game tokens (exp, crystal, and etc.) after battling or completing other in-game activities, which can then be used to upgrade in-game elements, i.e., improving their stats. Therefore, an RPG concerns with two main mechanisms: 1) categorization of in-game elements, and 2) interactions among in-game elements (battling, upgrading, and etc.)

We realized Pokemon is a good representation of the RPG as a game genre. In other words, every RPG game has similarities with Pokemon. Therefore, we are building the classic Pokemon Gen 2 (Gold/Silver/Crystal) to demonstrate our understanding of the RPG genre with the following features to implement:
1) **Separation between instances and classes** of RPG characters and ownable entities, thereby separating game builders and game players in a decentralization spirit
2) **Categorization of rights and authorization**, thereby allowing gameplay concepts to be built on each other in a hierachical and parallel order
3) **Experiment on turn-based team battle mechanisms**  

We aim to learn from building this project so that we can rapid-prototyping future game concepts. 

# Map  
The map is composed of 5x5 size parcels, on which players can build structures. The current data structure won't allow 10x10 size as it would cause "intrinsic gas too high" when players try to create a new parcel. There are ways to increase the parcel size limit: 1) implement the deterministic position entityID -> hash(x,y) to replace the Position Component; 2) initiate Position Component for players to build on top. However, small parcel size does have its advantage of setting up refined attributes of the map. 

In the official release, game project could sell parcels or rent editing rights to interested players. More thoughts are needed for this subject.

# Crawl
A player can move around the map, on foot, on bicycle, swim through water, encounter other pokemon, and enter into fights against other players.

# Pokemon
Pokemon instance is initiated through its Pokemon class, which the project governing body has the authority to set up and edit. We replicate (mostly) the stats system from Pokemon generation II, such as base stats, effort value, catch rate, etc. However, individual value is not introduced in this version, meaning that Pokemon instances are the same within the same class. 

# Move
Move is not an instance to be initiated. In other words, the pp value of a particular Pokemon's moves cannot be improved (at least in this version). The governing body would be in charge of setting up the stats for each move, including stats debuff/buff, status condition, and duration of the effect. Besides, the governing body need to set up the moves a Pokemon class can learn through leveling up.

# Battle


# Rights & Authorizations  
**Ownership**  
``HeroOwnedByComponent.sol``: mapping(HeroID -> Address)  
``WeaponOwnedByComponent.sol``
**Commanding**  
``TeamCommandedByComponent.sol``  
**Team**  
``HerosInTeam.sol``: mapping(HeroID -> TeamID)  

As to authorization on entity, there are various types of authorization players or contracts may have over entity, such as ownership, commanding, 

For example, to enter into a dungeon, a player needs to assemble a team from heroes he owns. Breaking it down, ownership changes hands from the player to the team component contract when a team is formed. Rights associated with ownership is no longer applicable to the player. In other words, the player can no longer transfer, authorize transfer, or call any other external function in an ERC721 contract on individual heroes in a team. 

The player now owns the team he created. There are then team-specific ownership rights the player can exercise. For instance, the player can exercise the team dissemble right, which could be stored in a team commander component, and be callable by a dissemble team system. There are also team-specific commanding rights the player can exercise. For instance, the player can order his team to enter into a dungeon, to move around within a dungeon, and to order team members to attack enemies. When a hero dies in a dungeon, the hero is permanently removed from the team, and therefore the player can no longer command it.

The benefit of defining rights and authorization is to allow concepts to be built on each other in a hierachical and parallel order. 

# Turn-Based Team Battle  
**Individual Hero Stats**  
``HeroHealthComponent.sol``: mapping(HeroID -> Health); enermy hero also counts as hero  
``HeroBuffsComponent.sol``: mapping(HeroID -> RPGStats01[])

Note: such arrangement is due to the fact that only health can be permanently changed during battle!!

When a battle is initiated, 4 enemy classes are selected to create 4 enemy instances to form a team along with setting their own health & buffs 

``TeamBattleTeamComponent.sol``: mapping(TeamID -> TeamID)  
``TeamBattleRoundComponent.sol``: mapping(TeamID -> HeroIDs[8]); it records whoever is left to make an attack move.

