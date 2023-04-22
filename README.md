make sure you switch to pokemona branch

# Roguelike X MUD

# Overview
An RPG is a game genre involving players strategically collecting and managing in-game elements (characters, equipment, skills, buffs, etc.). Players’ game goal is realized through "battling", in which players properly "stack" the stats of their in-game elements so as to achieve an optimized battling outcome. A feedback loop is then established by rewarding in-game tokens (exp, crystal, and etc.) after battling or completing other in-game activities, which can then be used to upgrade in-game elements, i.e., improving their stats. Therefore, an RPG concerns with two main mechanisms: 1) categorization of in-game elements, and 2) interactions among in-game elements (battling, upgrading, and etc.)

With these two concerns in mind, I use MUD's ECS (entity-component-system) model to realize three design patterns, which I believe to be vital/generic to on-chain RPGs:
1) **Separation between instances and classes** of RPG characters and ownable entities, thereby separating game builders and game players in a decentralization spirit
2) **Categorization of rights and authorization**, thereby allowing gameplay concepts to be built on each other in a hierachical and parallel order
3) **Experiment on turn-based team battle mechanisms**


# Class & Instance  
RPG in-game elements display the following relationships:
- Any tangible (or ownable) in-game elements can be perceived as an instance of a class. For example, Ash's pikachu is an instance of the general pikachu class, which is designed by Nintendo. 
- There are relationship between different classes. For example, the Pikachu class can learn lightingbolt attack skill, but Bulbasaur class cannot learn. 
- There are relationship between instances. For example, assuming Ash has a "leftover" item, he can pass it to the Pokemon he owns  
## Components  
**Class**  
``RPGStatsComponent01.sol``: the base component to describe an RPG in-game element  
``ClassHeroComponent.sol``: mapping(HeroClassID -> RPGStats01)  
``ClassWeaponComponent.sol``: mapping(WeaponClassID -> RPGStats01)  
``ClassAttackComponent.sol``: mapping(AttackClassID -> RPGStats01)  
``ClassDungeonComponent.sol``: mapping(DungeonClassID -> DungeonStats01)  
<!-- StatusClassComponent: mapping(StatusClassID -> RPGStats) -->
**Relations Among Classes**  
``ClassWeaponOnlyByClassHeroComponentsol``: mapping(WeaponClassID -> HeroClassID)  
``ClassAttackAvailableToClassHeroComponent.sol``: mapping(HeroClassID -> AttackClassID[])  
**Instance**  
``HeroComponent.sol``: mapping(HeroID -> HeroClassID)  
``WeaponComponent.sol``: mapping(HeroID -> WeaponClassID)  
``DungeonComponent.sol``: mapping(DungeonID -> DungeonClassID)  
**Relations Among Instances & Classes**  
``WeaponToHeroComponent.sol``: mapping(WeaponID -> HeroID)  
``AttackClassesAvailableToHeroComponent.sol``: mapping(HeroID -> AttackClassID[])  

As to class-instance entities, there are some general principles:
1) ownership indicates an owner’s sole right to dispose of entities as he sees fit;
2) ownable entities are created through the class objects of which the project itself takes control;
3) conceptual entities cannot be owned, and therefore have no instances. 
4) Some conceptual entities are NOT subject to players’ choices/will, but subject to game randomness engine (like a Beherit in Berserk :D)

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

