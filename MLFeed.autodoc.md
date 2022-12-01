# NS: MLFeed

## Functions

### GetGhostData -- `const SharedGhostDataHook_V2@ GetGhostData()`

Object exposing GhostInfos for each loaded ghost.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.
The list is cleared on map change.

### GetKoData -- `const KoDataProxy@ GetKoData()`

Your plugin's `KoDataProxy@` that exposes KO round information, and each player's , spawn info, and lists of players for each sorting method.
You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.

### GetPlayersBestTimes -- `const array<uint>@ GetPlayersBestTimes(const string &in playerName)`

Get a player's best CP times since the map loaded.
Deprecated: prefer PlayerCpInfo_V2.BestRaceTimes.

### GetRaceData -- `const RaceDataProxy@ GetRaceData()`

deprecated: prefer `MLFeed::GetRaceData_V2()`
Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.

### GetRaceData_V2 -- `const HookRaceStatsEventsBase_V2@ GetRaceData_V2()`

Exposes checkpoint data, spawn info, and lists of players for each sorting method.
You can call this function as often as you like.
Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)

### GhostInfo -- `GhostInfo@ GhostInfo(const MLHook::PendingEvent@ &in event)`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### GhostInfo_V2 -- `GhostInfo_V2@ GhostInfo_V2(const MLHook::PendingEvent@ &in event)`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### HookKoStatsEventsBase -- `HookKoStatsEventsBase@ HookKoStatsEventsBase(const string &in type)`

### HookRaceStatsEventsBase -- `HookRaceStatsEventsBase@ HookRaceStatsEventsBase(const string &in type)`

### HookRaceStatsEventsBase_V2 -- `HookRaceStatsEventsBase_V2@ HookRaceStatsEventsBase_V2(const string &in type)`

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### HookRecordEventsBase -- `HookRecordEventsBase@ HookRecordEventsBase(const string &in type)`

### KoDataProxy -- `KoDataProxy@ KoDataProxy(HookKoStatsEventsBase@ h)`

Main source of information about KO rounds.
Proxy for the internal type `KoFeed::HookKoStatsEvents`.

### KoPlayerState -- `KoPlayerState@ KoPlayerState(const string &in n)`

A player's state in a KO match

### KoPlayerState -- `KoPlayerState@ KoPlayerState(const string &in n, bool alive, bool dnf)`

A player's state in a KO match

### PlayerCpInfo -- `PlayerCpInfo@ PlayerCpInfo(MLHook::PendingEvent@ event, uint _spawnIndex)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo -- `PlayerCpInfo@ PlayerCpInfo(PlayerCpInfo@ _from, int cpOffset = 0)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo_V2 -- `PlayerCpInfo_V2@ PlayerCpInfo_V2(MLHook::PendingEvent@ event, uint _spawnIndex)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo_V2 -- `PlayerCpInfo_V2@ PlayerCpInfo_V2(PlayerCpInfo_V2@ _from, int cpOffset)`

Each's players status in the race, with a focus on CP related info.

### RaceDataProxy -- `RaceDataProxy@ RaceDataProxy(HookRaceStatsEventsBase@ h, HookRecordEventsBase@ rh)`

Provides race data.
It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`.

### SharedGhostDataHook -- `SharedGhostDataHook@ SharedGhostDataHook(const string &in type)`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.

### SharedGhostDataHook_V2 -- `SharedGhostDataHook_V2@ SharedGhostDataHook_V2(const string &in type)`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

## Properties

### `uint GameTime`

The current server's GameTime

### `const string LocalPlayersName`

returns the name of the local player, or an empty string if this is not yet known

# Types/Classes

## `enum Dir`

direction to move; down=-1, up=1

- `Down`
- `Up`


## `class GhostInfo`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### Functions

#### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

### Properties

#### `const array<uint>@ Checkpoints`

Ghost.Result.Checkpoints

#### `const string IdName`

Ghost.IdName

#### `uint IdUint`

Should be equiv to Ghost.Id.Value (experimental)

#### `const string Nickname`

Ghost.Nickname

#### `int Result_Score`

Ghost.Result.Score

#### `int Result_Time`

Ghost.Result.Time



## `class GhostInfo_V2`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### Functions

#### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

### Properties

#### `const array<uint>@ Checkpoints`

Ghost.Result.Checkpoints

#### `const string IdName`

Ghost.IdName

#### `uint IdUint`

Should be equiv to Ghost.Id.Value (experimental)

#### `bool IsLocalPlayer`

#### `bool IsPersonalBest`

#### `const string Nickname`

Ghost.Nickname

#### `int Result_Score`

Ghost.Result.Score

#### `int Result_Time`

Ghost.Result.Time



## `class HookKoStatsEventsBase`

### Functions

#### GetPlayerState -- `KoPlayerState@ GetPlayerState(const string &in name)`

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### `Meta::Plugin@ SourcePlugin`

#### `int division`

#### `int kosMilestone`

#### `int kosNumber`

#### `string lastGM`

#### `string lastMap`

#### `int mapRoundNb`

ServerNumber

#### `int mapRoundTotal`

#### `dictionary playerStates`

#### `array<string> players`

#### `int playersNb`

#### `int roundNb`

#### `int roundTotal`

#### `const string type`



## `class HookRaceStatsEventsBase`

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V2* get a player's cp info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### `uint LapCount`

The number of laps for this map.

#### `Meta::Plugin@ SourcePlugin`

#### `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### `string lastMap`

the prior map, prefer .Map

#### `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### `const string type`



## `class HookRaceStatsEventsBase_V2`

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V2* get a player's cp info

#### GetPlayer_V2 -- `const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const`

Get a player's info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### _GetPlayer_V2 -- `PlayerCpInfo_V2@ _GetPlayer_V2(const string &in name)`

internal

### Properties

#### `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### `uint LapCount`

The number of laps for this map.

#### `const string Map`

The map UID

#### `const array<PlayerCpInfo_V2>@ SortedPlayers_Race`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest.

#### `const array<PlayerCpInfo_V2>@ SortedPlayers_Race_Respawns`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

#### `const array<PlayerCpInfo_V2>@ SortedPlayers_TimeAttack`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

#### `Meta::Plugin@ SourcePlugin`

#### `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### `array<PlayerCpInfo_V2>@ _SortedPlayers_Race`

internal

#### `array<PlayerCpInfo_V2>@ _SortedPlayers_Race_Respawns`

internal

#### `array<PlayerCpInfo_V2>@ _SortedPlayers_TimeAttack`

internal

#### `string lastMap`

the prior map, prefer .Map

#### `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### `const string type`



## `class HookRecordEventsBase`

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### `Meta::Plugin@ SourcePlugin`

#### `const string type`



## `class KoDataProxy`

Main source of information about KO rounds.
Proxy for the internal type `KoFeed::HookKoStatsEvents`.

### Functions

#### GetPlayerState -- `const KoPlayerState@ GetPlayerState(const string &in name) const`

Get a player's MLFeed::KoPlayerState.
It has only 3 properties: `name`, `isAlive`, and `isDNF`.

### Properties

#### `int Division`

The current division number. *(Note: possibly inaccurate. Use with caution.)*

#### `const string GameMode`

The current game mode, e.g., `TM_KnockoutDaily_Online`, or `TM_TimeAttack_Online`, etc.

#### `int KOsMilestone`

KOs per round will change when the number of players is <= KOsMilestone.

#### `int KOsNumber`

KOs per round.

#### `const string Map`

The current map UID

#### `int MapRoundNb`

The current round number for this map.

#### `int MapRoundTotal`

The total number of rounds for this map.

#### `const array<string> Players`

A `string[]` of player names. It includes all players in the KO round, even if they've left.

#### `int PlayersNb`

The number of players participating.

#### `int RoundNb`

The round number over all maps. (I think)

#### `int RoundTotal`

The total number of rounds over all maps. (I think)



## `class KoPlayerState`

A player's state in a KO match



### Properties

#### `bool isAlive`

Whether the player is still 'in'; `false` implies they have been knocked out.

#### `bool isDNF`

Whether the player DNF'd or not. This is set to false the round after that player DNFs.

#### `string name`

The player's name.



## `class PlayerCpInfo`

Each's players status in the race, with a focus on CP related info.

### Functions

#### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"

#### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex)`

### Properties

#### `bool IsSpawned`

Whether the player is spawned

#### `int bestTime`

The player's best time this session

#### `int cpCount`

How many CPs that player currently has

#### `array<int> cpTimes`

The times of each of their CPs since respawning

#### `int lastCpTime`

Their last CP time as on their chronometer

#### `string name`

The player's name

#### `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### `uint spawnIndex`

The spawn index when the player spawned

#### `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## `class PlayerCpInfo_V2`

Each's players status in the race, with a focus on CP related info.

### Functions

#### ModifyRank -- `void ModifyRank(Dir dir, RankType rt)`

internal use

#### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, rr: 17, tr: 3, cp: 5 (0:43.231), Spawned, bt: 0:55.992)"

#### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"

#### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex, bool callSuper)`

internal use

#### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex)`

### Properties

#### `const array<uint>@ BestRaceTimes`

this player's CP times for their best performance this session (since the map loaded)

#### `int BestTime`

The player's best time this session

#### `int CpCount`

How many CPs that player currently has

#### `const array<int>@ CpTimes`

The times of each of their CPs since respawning

#### `int CurrentRaceTime`

This player's CurrentRaceTime with latency taken into account

#### `int CurrentRaceTimeRaw`

This player's CurrentRaceTime without accounting for latency

#### `bool IsLocalPlayer`

whether this player corresponds to the physical player playing the game

#### `bool IsSpawned`

Whether the player is spawned

#### `int LastCpOrRespawnTime`

Player's last CP time _OR_ their last respawn time if it is greater

#### `int LastCpTime`

Player's last CP time

#### `uint LastRespawnCheckpoint`

the last checkpoint that the player respawned at

#### `uint LastRespawnRaceTime`

the last time this player respawned (measure against CurrentRaceTime)

#### `int LastTheoreticalCpTime`

get the last CP time of the player minus time lost to respawns

#### `const string Name`

The player's name

#### `uint NbRespawnsRequested`

number of times the player has respawned

#### `uint RaceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### `uint RaceRespawnRank`

The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.

#### `uint SpawnIndex`

The spawn index when the player spawned

#### `SpawnStatus SpawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### `uint StartTime`

when the player spawned (measured against GameTime)

#### `uint TaRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

#### `int TheoreticalRaceTime`

get the current race time of this player minus time lost to respawns

#### `const array<int>@ TimeLostToRespawnByCp`

The times of each of their CPs since respawning

#### `uint TimeLostToRespawns`

the amount of time the player has lost due to respawns

#### `int bestTime`

The player's best time this session

#### `int cpCount`

How many CPs that player currently has

#### `array<int> cpTimes`

The times of each of their CPs since respawning

#### `float lagDataPoints`

#### `int lastCpTime`

Their last CP time as on their chronometer

#### `float latencyEstimate`

an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it

#### `string name`

The player's name

#### `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### `int raceRespawnRank`

#### `uint spawnIndex`

The spawn index when the player spawned

#### `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## `class RaceDataProxy`

Provides race data.
It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`.

### Functions

#### GetPlayer -- `const PlayerCpInfo@ GetPlayer(const string &in name) const`

Get a player by name (see `.SortedPlayers_Race/TimeAttack` for players)

### Properties

#### `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### `uint LapCount`

The number of laps for this map.

#### `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### `const string Map`

The map UID

#### `const array<PlayerCpInfo> SortedPlayers_Race`

An array of `PlayerCpInfo`s sorted by most checkpoints to fewest.

#### `const array<PlayerCpInfo> SortedPlayers_TimeAttack`

An array of `PlayerCpInfo`s sorted by best time to worst time.

#### `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.



## `enum RankType`

sort method for players

- `Race`
- `RaceRespawns`
- `TimeAttack`


## `class SharedGhostDataHook`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### `const array<MLFeed::GhostInfo> Ghosts`

Array of GhostInfos

#### `uint NbGhosts`

Number of currently loaded ghosts

#### `Meta::Plugin@ SourcePlugin`

#### `const string type`



## `class SharedGhostDataHook_V2`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### `const array<MLFeed::GhostInfo> Ghosts`

Array of GhostInfos

#### `const array<MLFeed::GhostInfo_V2> Ghosts_V2`

Array of GhostInfo_V2s

#### `uint NbGhosts`

Number of currently loaded ghosts

#### `Meta::Plugin@ SourcePlugin`

#### `const string type`



## `enum SpawnStatus`

The spawn status of a player.

- `NotSpawned`
- `Spawning`
- `Spawned`
