# Roguelike X MUD

# Overview
An RPG is a game genre involving players strategically collecting and managing in-game elements (characters, equipment, skills, buffs, etc.). Players’ game goal is realized through "battling", in which players properly "stack" the stats of their in-game elements so as to achieve an optimized battling outcome. A feedback loop is then established by rewarding in-game tokens (exp, crystal, and etc.) after battling or completing other in-game activities, which can then be used to upgrade in-game elements, i.e., improving their stats. Therefore, an RPG concerns with two main mechanisms: 1) categorization of in-game elements, and 2) interactions among in-game elements (battling, upgrading, and etc.)

We categorize an RPG game to have 4 essential elements:
1) Characters 
2) Equipment
3) Map to crawl
4) Battle to fight

We are building the classic Pokemon Gen 2 (Gold/Silver/Crystal) to demonstrate our understanding of the RPG genre with the following features to implement:
1) **Separation between instances and classes** of RPG characters and ownable entities, thereby separating game builders and game players in a decentralization spirit
2) **Categorization of rights and authorization**, thereby allowing gameplay concepts to be built on each other in a hierachical and parallel order
3) **Experiment on turn-based team battle mechanisms**  

We aim to learn from building this project so that we can rapid-prototyping other future RPG games. More importantly, we want to create an RPG world where different RPG games can share assets and gameplay and allow players to play across games. 

# Pokemon
Pokemon is the main playable character during the gameplay. Its in-game performance is dictated by its individual stats and its class stats, which are described in `components` below. Rules, such as who can create new classes or how players can spawn new instances, are described in `libraries` and implemented in `systems`.

Such a separation between character instance and class would allow easier on-boarding of new in-game asset.

## Pokemon Class  
`ClassBaseStats`:  records base stats for a pokemon class   

`ClassEffortValue`:  records effort value for a pokemon class  

`ClassIndex`:  records index number for a pokemon class  

`ClassInfo`:  records class info for a pokemon class  


## Pokemon Instance  
`PokemonBattleStats`: records battle stats for a pokemon instance   

`PokemonClassID`:  records pokemon classID for a pokemon instance   

`PokemonEV`:  records pokemon effort value for a pokemon instance  

`PokemonExp`:  record exp of a pokemon instance  

`PokemonHP`: record current HP for a pokemon instance  

`PokemonItem`:  records item held by a pokemon instance  

`PokemonLevel`: records level

`PokemonMoves`: record moveIDs pokemon can make  

`PokemonNickname`: record pokemon instance's nickname  


# Move
A move describes the move action a character can perform. There is no separation between class and instance for moves as move is not an instance to be initiated. In other words, the pp value of a particular Pokemon's moves cannot be improved (at least in this version). The governing body would be in charge of setting up the stats for each move, including stats debuff/buff, status condition, and duration of the effect. Besides, the governing body need to set up the moves a Pokemon class can learn through leveling up.  

`MoveEffect`: records move's effect of a move class  

`MoveInfo`:  records move's info of a move class  

`MoveName`:  records move's name of a move class    

# Team
"Team" represents a player's right to enter into a battle. 

To fight against other players, NPCs, or wild pokemons, a player needs to create a team with up to 4 pokemons as team members. When setting up, the teamID becomes the owner of each individual pokemon; playerID the owner of teamID. In that sense, an NPC or wild pokemons are in teams commanded by smart contract (BattleSystemID). When pokemon dies, its owner is removed from team to the dungeon where it dies. New systems can be deployed to allow summoning dead pokemons from dungeon.  

`Team`:  records the commanding playerID of a team  

`TeamPokemons`:  records the 4 team member pokemonID of a team; when no team for a slot, use zero instead  

# Battle  
"Battle" represents a privileged and restricted state a player is forced or voluntarily into. 

Restricted because the player's team is subject to BattleSystem's rule and may incur stats decrease from the enemy team. Besides, some ownership rights previously provided to team owners is revoked during battle, such as the right to change team members. 

Privileged because a player may decrease stats of other players' pokemons, there is an opportunity to catch new pokemon, or to gain new abilities through leveling up. 

`TeamBattle`:  records the battleID for a team  

`BattlePokemons`: records battle order, an array of pokemons who has turn to act in a battle


# Map  
The map is composed of 5x5 size parcels, on which players can build structures. The current data structure (MUD v1) won't allow 10x10 size as it would cause "intrinsic gas too high" error when players try to create a new parcel. There are ways to increase the parcel size limit: 1) implement the deterministic position entityID -> hash(x,y) to replace the Position Component; 2) initiate Position Component for players to build on top. However, small parcel size does have its advantage of setting up refined attributes of the map. 

In the official release, game project could sell parcels or rent out editing rights to interested players. More thoughts are needed for this subject.

`Position`: entityID -> Coord(x,y)  

`Player`: entityID -> Bool

`Encounter`: entityID -> Bool  

`Obstruction`: entityID -> Bool  

`Parcel`: parcelID -> Parcel(x_parcel, y_parcel, terrain); should change it to parcelID -> terrain  

`ParcelCoord`: parcelID -> Coord(x,y)  

`DungeonLevel`: parcelID -> uint32  

`DungeonPokemons`: parcelID -> class index[]

There are parcels that are not dungeon (i.e., not use CreateDungeonSystem). Make sure NOT to put any encounterable terrainType on it. Otherwise, would cause error when stepping on it. 

# Crawl
A player can move around the map, on foot, on bicycle, swim through water, encounter other pokemon, and enter into fights against other players.

Without forming a team, a player may still be able to crawl around. But, he needs a team with at least 1 pokemon in it to step on encounterable terrainType (i.e., revert transaction otherwise)

# Rights & Authorizations  
 

As to authorization on entity, there are various types of authorization players or contracts may have over entity, such as ownership, commanding, 

For example, to enter into a dungeon, a player needs to assemble a team from heroes he owns. Breaking it down, ownership changes hands from the player to the team component contract when a team is formed. Rights associated with ownership is no longer applicable to the player. In other words, the player can no longer transfer, authorize transfer, or call any other external function in an ERC721 contract on individual heroes in a team. 

The player now owns the team he created. There are then team-specific ownership rights the player can exercise. For instance, the player can exercise the team dissemble right, which could be stored in a team commander component, and be callable by a dissemble team system. There are also team-specific commanding rights the player can exercise. For instance, the player can order his team to enter into a dungeon, to move around within a dungeon, and to order team members to attack enemies. When a hero dies in a dungeon, the hero is permanently removed from the team, and therefore the player can no longer command it.

The benefit of defining rights and authorization is to allow concepts to be built on each other in a hierachical and parallel order. 

# Features To Be Added  

## Summon Dead Pokemon 
allow original owner to summon dead pokemon from a specific parcelID
- Add a PokemonOriginalOwnerComponent, and write to it when _handlePokemonCaught()
- Set ownership to parcelID when handlePokemonDead()
- Add a SummonPokemonSystem to allow player to summon with Nickname, which would check 1) whether parcelID owned Nickname's pokemonID, 2) whehther player is the original owner; it then spawn it with full HP allowing player to fight/capture it.
- Additional rules can be added: 1) player cannot escape, 2) dead pokemon would be owned by address(0) when defeated. 


