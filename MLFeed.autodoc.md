# NS: MLFeed



## Functions

### GetGhostData -- `const SharedGhostDataHook_V2@ GetGhostData()`

Object exposing GhostInfos for each loaded ghost.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
The list is cleared on map change.

### GetKoData -- `const KoDataProxy@ GetKoData()`

Your plugin's `KoDataProxy@` that exposes KO round information, and each player's spawn info, and lists of players for each sorting method.
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

### GetRaceData_V3 -- `const HookRaceStatsEventsBase_V3@ GetRaceData_V3()`

Exposes checkpoint data, spawn info, and lists of players for each sorting method.
You can call this function as often as you like.
Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)

### GetRaceData_V4 -- `const HookRaceStatsEventsBase_V4@ GetRaceData_V4()`

Exposes checkpoint data, spawn info, and lists of players for each sorting method.
You can call this function as often as you like.
Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)

### GetTeamsMMData_V1 -- `const HookTeamsMMEventsBase_V1@ GetTeamsMMData_V1()`

Object exposing info about the current Matchmaking Teams game.
Includes warm up, team points, when new rounds begin, current MVP, players finished, and points prediction.

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

### HookRaceStatsEventsBase_V3 -- `HookRaceStatsEventsBase_V3@ HookRaceStatsEventsBase_V3(const string &in type)`

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### HookRaceStatsEventsBase_V4 -- `HookRaceStatsEventsBase_V4@ HookRaceStatsEventsBase_V4(const string &in type)`

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### HookRecordEventsBase -- `HookRecordEventsBase@ HookRecordEventsBase(const string &in type)`

### HookTeamsMMEventsBase_V1 -- `HookTeamsMMEventsBase_V1@ HookTeamsMMEventsBase_V1(const string &in type)`

Info about MM: game state, team points, player points (this round and total), current MVP

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

### PlayerCpInfo_V3 -- `PlayerCpInfo_V3@ PlayerCpInfo_V3(MLHook::PendingEvent@ event, uint _spawnIndex)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo_V3 -- `PlayerCpInfo_V3@ PlayerCpInfo_V3(PlayerCpInfo_V3@ _from, int cpOffset)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo_V4 -- `PlayerCpInfo_V4@ PlayerCpInfo_V4(MLHook::PendingEvent@ event, uint _spawnIndex)`

Each's players status in the race, with a focus on CP related info.

### PlayerCpInfo_V4 -- `PlayerCpInfo_V4@ PlayerCpInfo_V4(PlayerCpInfo_V4@ _from, int cpOffset)`

Each's players status in the race, with a focus on CP related info.

### RaceDataProxy -- `RaceDataProxy@ RaceDataProxy(HookRaceStatsEventsBase@ h, HookRecordEventsBase@ rh)`

Provides race data.
It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`.

### SharedGhostDataHook -- `SharedGhostDataHook@ SharedGhostDataHook(const string &in type)`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).

### SharedGhostDataHook_V2 -- `SharedGhostDataHook_V2@ SharedGhostDataHook_V2(const string &in type)`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

## Properties

### GameTime -- `uint GameTime`

The current server's GameTime, or 0 if not in a server

### LocalPlayersName -- `const string LocalPlayersName`

returns the name of the local player, or an empty string if this is not yet known

# Types/Classes

## MLFeed::Dir (enum)

direction to move; down=-1, up=1

- `Down`
- `Up`


## MLFeed::GetTeamsMMData_V1 (class)

```angelscript_snippet
funcdef const HookTeamsMMEventsBase_V1@ GetTeamsMMData_V1();
```







## MLFeed::GhostInfo (class)

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### Functions

#### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

### Properties

#### Checkpoints -- `const array<uint>@ Checkpoints`

Ghost.Result.Checkpoints

#### IdName -- `const string IdName`

Ghost.IdName

#### IdUint -- `uint IdUint`

Should be equiv to Ghost.Id.Value (experimental)

#### Nickname -- `const string Nickname`

Ghost.Nickname

#### Result_Score -- `int Result_Score`

Ghost.Result.Score

#### Result_Time -- `int Result_Time`

Ghost.Result.Time



## MLFeed::GhostInfo_V2 (class)

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### Functions

#### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

### Properties

#### Checkpoints -- `const array<uint>@ Checkpoints`

Ghost.Result.Checkpoints

#### IdName -- `const string IdName`

Ghost.IdName

#### IdUint -- `uint IdUint`

Should be equiv to Ghost.Id.Value (experimental)

#### IsLocalPlayer -- `bool IsLocalPlayer`

Whether this is the local player (sitting at this computer)

#### IsPersonalBest -- `bool IsPersonalBest`

Whether this is a PB ghost (named: 'Personal best')

#### Nickname -- `const string Nickname`

Ghost.Nickname

#### Result_Score -- `int Result_Score`

Ghost.Result.Score

#### Result_Time -- `int Result_Time`

Ghost.Result.Time



## MLFeed::HookKoStatsEventsBase (class)

### Functions

#### GetPlayerState -- `KoPlayerState@ GetPlayerState(const string &in name)`

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### division -- `int division`

ServerNumber

#### kosMilestone -- `int kosMilestone`

#### kosNumber -- `int kosNumber`

#### lastGM -- `string lastGM`

#### lastMap -- `string lastMap`

#### mapRoundNb -- `int mapRoundNb`

#### mapRoundTotal -- `int mapRoundTotal`

#### playerStates -- `dictionary playerStates`

#### players -- `array<string> players`

#### playersNb -- `int playersNb`

#### roundNb -- `int roundNb`

#### roundTotal -- `int roundTotal`

#### type -- `const string type`



## MLFeed::HookRaceStatsEventsBase (class)

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V4* get a player's cp info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### CPsToFinish -- `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### CpCount -- `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### LapCount -- `uint LapCount`

The number of laps for this map.

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### lastMap -- `string lastMap`

the prior map, prefer .Map

#### latestPlayerStats -- `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### sortedPlayers_Race -- `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### sortedPlayers_TimeAttack -- `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### type -- `const string type`



## MLFeed::HookRaceStatsEventsBase_V2 (class)

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V4* get a player's cp info

#### GetPlayer_V2 -- `const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const`

Get a player's info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### _GetPlayer_V2 -- `PlayerCpInfo_V2@ _GetPlayer_V2(const string &in name)`

internal

### Properties

#### CPCount -- `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### CPsToFinish -- `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### CpCount -- `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### LapCount -- `uint LapCount`

The number of laps for this map.

#### LastRecordTime -- `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### Map -- `const string Map`

The map UID

#### SortedPlayers_Race -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest.

#### SortedPlayers_Race_Respawns -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race_Respawns`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

#### SortedPlayers_TimeAttack -- `const array<PlayerCpInfo_V2>@ SortedPlayers_TimeAttack`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### _SortedPlayers_Race -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race`

internal

#### _SortedPlayers_Race_Respawns -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race_Respawns`

internal

#### _SortedPlayers_TimeAttack -- `array<PlayerCpInfo_V2>@ _SortedPlayers_TimeAttack`

internal

#### lastMap -- `string lastMap`

the prior map, prefer .Map

#### latestPlayerStats -- `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### sortedPlayers_Race -- `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### sortedPlayers_TimeAttack -- `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### type -- `const string type`



## MLFeed::HookRaceStatsEventsBase_V3 (class)

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V4* get a player's cp info

#### GetPlayer_V2 -- `const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const`

Get a player's info

#### GetPlayer_V3 -- `const PlayerCpInfo_V3@ GetPlayer_V3(const string &in name) const`

Get a player's info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### _GetPlayer_V2 -- `PlayerCpInfo_V2@ _GetPlayer_V2(const string &in name)`

internal

#### _GetPlayer_V3 -- `PlayerCpInfo_V3@ _GetPlayer_V3(const string &in name)`

internal

### Properties

#### CPCount -- `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### CPsToFinish -- `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### CpCount -- `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### LapCount -- `uint LapCount`

The number of laps for this map.

#### LastRecordTime -- `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### Map -- `const string Map`

The map UID

#### SortedPlayers_Race -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest.

#### SortedPlayers_Race_Respawns -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race_Respawns`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

#### SortedPlayers_TimeAttack -- `const array<PlayerCpInfo_V2>@ SortedPlayers_TimeAttack`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### _SortedPlayers_Race -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race`

internal

#### _SortedPlayers_Race_Respawns -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race_Respawns`

internal

#### _SortedPlayers_TimeAttack -- `array<PlayerCpInfo_V2>@ _SortedPlayers_TimeAttack`

internal

#### lastMap -- `string lastMap`

the prior map, prefer .Map

#### latestPlayerStats -- `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### sortedPlayers_Race -- `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### sortedPlayers_TimeAttack -- `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### type -- `const string type`



## MLFeed::HookRaceStatsEventsBase_V4 (class)

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### Functions

#### GetPlayer -- `PlayerCpInfo@ GetPlayer(const string &in name)`

*deprecated; use GetPlayer_V4* get a player's cp info

#### GetPlayer_V2 -- `const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const`

Get a player's info

#### GetPlayer_V3 -- `const PlayerCpInfo_V3@ GetPlayer_V3(const string &in name) const`

Get a player's info

#### GetPlayer_V4 -- `const PlayerCpInfo_V4@ GetPlayer_V4(const string &in name) const`

Get a player's info

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

#### _GetPlayer_V2 -- `PlayerCpInfo_V2@ _GetPlayer_V2(const string &in name)`

internal

#### _GetPlayer_V3 -- `PlayerCpInfo_V3@ _GetPlayer_V3(const string &in name)`

internal

#### _GetPlayer_V4 -- `PlayerCpInfo_V4@ _GetPlayer_V4(const string &in name)`

internal

### Properties

#### CPCount -- `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### CPsToFinish -- `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### CpCount -- `uint CpCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### LapCount -- `uint LapCount`

The number of laps for this map.

#### LastRecordTime -- `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### Map -- `const string Map`

The map UID

#### SortedPlayers_Race -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest.

#### SortedPlayers_Race_Respawns -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race_Respawns`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

#### SortedPlayers_TimeAttack -- `const array<PlayerCpInfo_V2>@ SortedPlayers_TimeAttack`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### _SortedPlayers_Race -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race`

internal

#### _SortedPlayers_Race_Respawns -- `array<PlayerCpInfo_V2>@ _SortedPlayers_Race_Respawns`

internal

#### _SortedPlayers_TimeAttack -- `array<PlayerCpInfo_V2>@ _SortedPlayers_TimeAttack`

internal

#### lastMap -- `string lastMap`

the prior map, prefer .Map

#### latestPlayerStats -- `dictionary latestPlayerStats`

internal... but it's a map of player name => player object

#### sortedPlayers_Race -- `array<PlayerCpInfo> sortedPlayers_Race`

internal, deprecated

#### sortedPlayers_TimeAttack -- `array<PlayerCpInfo> sortedPlayers_TimeAttack`

internal, deprecated

#### type -- `const string type`



## MLFeed::HookRecordEventsBase (class)

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### LastRecordTime -- `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### type -- `const string type`



## MLFeed::HookTeamsMMEventsBase_V1 (class)

Info about MM: game state, team points, player points (this round and total), current MVP

### Functions

#### ComputePoints -- `void ComputePoints(const int[]@ finishedTeamOrder, int[]@ points, int[]@ teamPoints) const`

Pass in a list of player.TeamNum for a finishing order, and 2 arrays that will be written to: the first will contain the points earned by each player for their team, the second contains the total points for each team (length 3).

Usage: teamPoints[player.TeamNum]

Implementation reference: ComputeLatestRaceScores in Titles/Trackmania/Scripts/Libs/Nadeo/ModeLibs/TrackMania/Teams/TeamsCommon.Script.txt

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### ClanScores -- `array<int>@ ClanScores`

Rounds won by team. Updated each round as soon as the last player despawns. Blue at index 1, Red at index 2. Length: 31.

#### MvpAccountId -- `string MvpAccountId`

Current MVP's account id. Updated with scores.

#### MvpName -- `string MvpName`

Current MVP's name. Updated with scores.

#### PlayerFinishedRaceUpdate -- `int PlayerFinishedRaceUpdate`

The last game time that a player finished and the corresponding lists were updated.

#### PlayersFinishedLogins -- `array<string>@ PlayersFinishedLogins`

Player logins in finishing order. Updated when a player finishes and at the start of the race.

#### PlayersFinishedNames -- `array<string>@ PlayersFinishedNames`

Player names in finishing order. Updated when a player finishes and at the start of the race.

#### PointsLimit -- `int PointsLimit`

A team wins when they reach this many points. Set after warmup.

#### PointsRepartition -- `array<int>@ PointsRepartition`

The points available for each position, set after warmup and updated at the start of the next race (after a player leaves).

#### RankingMode -- `int RankingMode`

Ranking mode used. 0 = BestRace, 1 = CurrentRace. (MM uses 1)

#### RoundNumber -- `int RoundNumber`

The current round. Incremented at the completion of each round. (RoundNumber will end +1 more than StartNewRace.)

#### RoundWinningClan -- `int RoundWinningClan`

set to -1 on race start, and set to 1 or 2 at end of race indicating the winning team. 0 = draw.

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### StartNewRace -- `int StartNewRace`

Increments each race as a flag to reset state. 0 during warmup. 1 during first round, etc.

#### TeamPopulations -- `array<int>@ TeamPopulations`

The number of players on each team. Length is always 31.

#### TeamsUnbalanced -- `bool TeamsUnbalanced`

Whether the populations of the teams is unequal.

#### WarmUpIsActive -- `bool WarmUpIsActive`

True when the warmup is active.

#### type -- `const string type`



## MLFeed::KoDataProxy (class)

Main source of information about KO rounds.
Proxy for the internal type `KoFeed::HookKoStatsEvents`.

### Functions

#### GetPlayerState -- `const KoPlayerState@ GetPlayerState(const string &in name) const`

Get a player's MLFeed::KoPlayerState.
It has only 3 properties: `name`, `isAlive`, and `isDNF`.

### Properties

#### Division -- `int Division`

The current division number. *(Note: possibly inaccurate. Use with caution.)*

#### GameMode -- `const string GameMode`

The current game mode, e.g., `TM_KnockoutDaily_Online`, or `TM_TimeAttack_Online`, etc.

#### KOsMilestone -- `int KOsMilestone`

KOs per round will change when the number of players is <= KOsMilestone.

#### KOsNumber -- `int KOsNumber`

KOs per round.

#### Map -- `const string Map`

The current map UID

#### MapRoundNb -- `int MapRoundNb`

The current round number for this map.

#### MapRoundTotal -- `int MapRoundTotal`

The total number of rounds for this map.

#### Players -- `const array<string> Players`

A `string[]` of player names. It includes all players in the KO round, even if they've left.

#### PlayersNb -- `int PlayersNb`

The number of players participating.

#### RoundNb -- `int RoundNb`

The round number over all maps. (I think)

#### RoundTotal -- `int RoundTotal`

The total number of rounds over all maps. (I think)



## MLFeed::KoPlayerState (class)

A player's state in a KO match



### Properties

#### isAlive -- `bool isAlive`

Whether the player is still 'in'; `false` implies they have been knocked out.

#### isDNF -- `bool isDNF`

Whether the player DNF'd or not. This is set to false the round after that player DNFs.

#### name -- `string name`

The player's name.



## MLFeed::PlayerCpInfo (class)

Each's players status in the race, with a focus on CP related info.

### Functions

#### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"

#### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex)`

### Properties

#### IsSpawned -- `bool IsSpawned`

Whether the player is spawned

#### bestTime -- `int bestTime`

The player's best time this session

#### cpCount -- `int cpCount`

How many CPs that player currently has

#### cpTimes -- `array<int> cpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### lastCpTime -- `int lastCpTime`

Their last CP time as on their chronometer

#### name -- `string name`

The player's name

#### raceRank -- `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### spawnIndex -- `uint spawnIndex`

The spawn index when the player spawned

#### spawnStatus -- `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### taRank -- `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## MLFeed::PlayerCpInfo_V2 (class)

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

#### BestRaceTimes -- `const array<uint>@ BestRaceTimes`

this player's CP times for their best performance this session (since the map loaded)

#### BestTime -- `int BestTime`

The player's best time this session

#### CpCount -- `int CpCount`

How many CPs that player currently has

#### CpTimes -- `const array<int>@ CpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### CurrentRaceTime -- `int CurrentRaceTime`

This player's CurrentRaceTime with latency taken into account

#### CurrentRaceTimeRaw -- `int CurrentRaceTimeRaw`

This player's CurrentRaceTime without accounting for latency

#### IsLocalPlayer -- `bool IsLocalPlayer`

whether this player corresponds to the physical player playing the game

#### IsSpawned -- `bool IsSpawned`

Whether the player is spawned

#### LastCpOrRespawnTime -- `int LastCpOrRespawnTime`

Player's last CP time _OR_ their last respawn time if it is greater

#### LastCpTime -- `int LastCpTime`

Player's last CP time as on their chronometer

#### LastRespawnCheckpoint -- `uint LastRespawnCheckpoint`

the last checkpoint that the player respawned at

#### LastRespawnRaceTime -- `uint LastRespawnRaceTime`

the last time this player respawned (measure against CurrentRaceTime)

#### LastTheoreticalCpTime -- `int LastTheoreticalCpTime`

get the last CP time of the player minus time lost to respawns

#### Name -- `const string Name`

The player's name

#### NbRespawnsRequested -- `uint NbRespawnsRequested`

number of times the player has respawned

#### RaceRank -- `uint RaceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### RaceRespawnRank -- `uint RaceRespawnRank`

The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.

#### SpawnIndex -- `uint SpawnIndex`

The spawn index when the player spawned

#### SpawnStatus -- `SpawnStatus SpawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### StartTime -- `uint StartTime`

when the player spawned (measured against GameTime)

#### TaRank -- `uint TaRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

#### TheoreticalRaceTime -- `int TheoreticalRaceTime`

get the current race time of this player minus time lost to respawns

#### TimeLostToRespawnByCp -- `const array<int>@ TimeLostToRespawnByCp`

The time lost due to respawning at each CP

#### TimeLostToRespawns -- `uint TimeLostToRespawns`

the amount of time the player has lost due to respawns in total since the start of their current race/attempt

#### bestTime -- `int bestTime`

The player's best time this session

#### cpCount -- `int cpCount`

How many CPs that player currently has

#### cpTimes -- `array<int> cpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### lagDataPoints -- `float lagDataPoints`

#### lastCpTime -- `int lastCpTime`

Their last CP time as on their chronometer

#### latencyEstimate -- `float latencyEstimate`

an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it

#### name -- `string name`

The player's name

#### raceRank -- `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### raceRespawnRank -- `int raceRespawnRank`

#### spawnIndex -- `uint spawnIndex`

The spawn index when the player spawned

#### spawnStatus -- `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### taRank -- `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## MLFeed::PlayerCpInfo_V3 (class)

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

#### BestLapTimes -- `const array<uint>@ BestLapTimes`

this player's CP times for their best lap this session, measured from the start of the lap.

#### BestRaceTimes -- `const array<uint>@ BestRaceTimes`

this player's CP times for their best performance this session (since the map loaded)

#### BestTime -- `int BestTime`

The player's best time this session

#### CpCount -- `int CpCount`

How many CPs that player currently has

#### CpTimes -- `const array<int>@ CpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### CurrentRaceTime -- `int CurrentRaceTime`

This player's CurrentRaceTime with latency taken into account

#### CurrentRaceTimeRaw -- `int CurrentRaceTimeRaw`

This player's CurrentRaceTime without accounting for latency

#### IsLocalPlayer -- `bool IsLocalPlayer`

whether this player corresponds to the physical player playing the game

#### IsSpawned -- `bool IsSpawned`

Whether the player is spawned

#### LastCpOrRespawnTime -- `int LastCpOrRespawnTime`

Player's last CP time _OR_ their last respawn time if it is greater

#### LastCpTime -- `int LastCpTime`

Player's last CP time as on their chronometer

#### LastRespawnCheckpoint -- `uint LastRespawnCheckpoint`

the last checkpoint that the player respawned at

#### LastRespawnRaceTime -- `uint LastRespawnRaceTime`

the last time this player respawned (measure against CurrentRaceTime)

#### LastTheoreticalCpTime -- `int LastTheoreticalCpTime`

get the last CP time of the player minus time lost to respawns

#### Name -- `const string Name`

The player's name

#### NbRespawnsRequested -- `uint NbRespawnsRequested`

number of times the player has respawned

#### RaceRank -- `uint RaceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### RaceRespawnRank -- `uint RaceRespawnRank`

The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.

#### SpawnIndex -- `uint SpawnIndex`

The spawn index when the player spawned

#### SpawnStatus -- `SpawnStatus SpawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### StartTime -- `uint StartTime`

when the player spawned (measured against GameTime)

#### TaRank -- `uint TaRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

#### TheoreticalRaceTime -- `int TheoreticalRaceTime`

get the current race time of this player minus time lost to respawns

#### TimeLostToRespawnByCp -- `const array<int>@ TimeLostToRespawnByCp`

The time lost due to respawning at each CP

#### TimeLostToRespawns -- `uint TimeLostToRespawns`

the amount of time the player has lost due to respawns in total since the start of their current race/attempt

#### bestTime -- `int bestTime`

The player's best time this session

#### cpCount -- `int cpCount`

How many CPs that player currently has

#### cpTimes -- `array<int> cpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### lagDataPoints -- `float lagDataPoints`

#### lastCpTime -- `int lastCpTime`

Their last CP time as on their chronometer

#### latencyEstimate -- `float latencyEstimate`

an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it

#### name -- `string name`

The player's name

#### raceRank -- `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### raceRespawnRank -- `int raceRespawnRank`

#### spawnIndex -- `uint spawnIndex`

The spawn index when the player spawned

#### spawnStatus -- `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### taRank -- `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## MLFeed::PlayerCpInfo_V4 (class)

Each's players status in the race, with a focus on CP related info.

### Functions

#### FindCSmPlayer -- `CSmPlayer@ FindCSmPlayer()`

Return's the players CSmPlayer object if it is available, otherwise null. The full list of players is searched each time.

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

#### BestLapTimes -- `const array<uint>@ BestLapTimes`

this player's CP times for their best lap this session, measured from the start of the lap.

#### BestRaceTimes -- `const array<uint>@ BestRaceTimes`

this player's CP times for their best performance this session (since the map loaded)

#### BestTime -- `int BestTime`

The player's best time this session

#### CpCount -- `int CpCount`

How many CPs that player currently has

#### CpTimes -- `const array<int>@ CpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### CurrentLap -- `uint CurrentLap`

The player's current lap.

#### CurrentRaceTime -- `int CurrentRaceTime`

This player's CurrentRaceTime with latency taken into account

#### CurrentRaceTimeRaw -- `int CurrentRaceTimeRaw`

This player's CurrentRaceTime without accounting for latency

#### IsLocalPlayer -- `bool IsLocalPlayer`

whether this player corresponds to the physical player playing the game

#### IsMVP -- `bool IsMVP`

Whether the player is currently the MVP (for MM / Ranked)

#### IsSpawned -- `bool IsSpawned`

Whether the player is spawned

#### LastCpOrRespawnTime -- `int LastCpOrRespawnTime`

Player's last CP time _OR_ their last respawn time if it is greater

#### LastCpTime -- `int LastCpTime`

Player's last CP time as on their chronometer

#### LastRespawnCheckpoint -- `uint LastRespawnCheckpoint`

the last checkpoint that the player respawned at

#### LastRespawnRaceTime -- `uint LastRespawnRaceTime`

the last time this player respawned (measure against CurrentRaceTime)

#### LastTheoreticalCpTime -- `int LastTheoreticalCpTime`

get the last CP time of the player minus time lost to respawns

#### Login -- `string Login`

The player's Login (note: if you can, use WebServicesUserId instead)

#### Name -- `const string Name`

The player's name

#### NbRespawnsRequested -- `uint NbRespawnsRequested`

number of times the player has respawned

#### Points -- `int Points`

The points total of this player. Updated with +RoundPoints on EndRound UI sequence (before RoundPoints is reset).

#### RaceRank -- `uint RaceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### RaceRespawnRank -- `uint RaceRespawnRank`

The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.

#### RoundPoints -- `int RoundPoints`

The points the player earned this round. Reset on Playing UI sequence.

#### SpawnIndex -- `uint SpawnIndex`

The spawn index when the player spawned

#### SpawnStatus -- `SpawnStatus SpawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### StartTime -- `uint StartTime`

when the player spawned (measured against GameTime)

#### TaRank -- `uint TaRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

#### TeamNum -- `int TeamNum`

The team the player is on. 1 = Blue, 2 = Red.

#### TheoreticalRaceTime -- `int TheoreticalRaceTime`

get the current race time of this player minus time lost to respawns

#### TimeLostToRespawnByCp -- `const array<int>@ TimeLostToRespawnByCp`

The time lost due to respawning at each CP

#### TimeLostToRespawns -- `uint TimeLostToRespawns`

the amount of time the player has lost due to respawns in total since the start of their current race/attempt

#### WebServicesUserId -- `string WebServicesUserId`

The player's WebServicesUserId

#### bestTime -- `int bestTime`

The player's best time this session

#### cpCount -- `int cpCount`

How many CPs that player currently has

#### cpTimes -- `array<int> cpTimes`

The CP times of that player (including the 0th cp at the 0th index; which will always be 0)

#### lagDataPoints -- `float lagDataPoints`

#### lastCpTime -- `int lastCpTime`

Their last CP time as on their chronometer

#### latencyEstimate -- `float latencyEstimate`

an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it

#### name -- `string name`

The player's name

#### raceRank -- `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

#### raceRespawnRank -- `int raceRespawnRank`

#### spawnIndex -- `uint spawnIndex`

The spawn index when the player spawned

#### spawnStatus -- `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

#### taRank -- `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



## MLFeed::RaceDataProxy (class)

Provides race data.
It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`.

### Functions

#### GetPlayer -- `const PlayerCpInfo@ GetPlayer(const string &in name) const`

Get a player by name (see `.SortedPlayers_Race/TimeAttack` for players)

### Properties

#### CPCount -- `uint CPCount`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

#### CPsToFinish -- `uint CPsToFinish`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

#### LapCount -- `uint LapCount`

The number of laps for this map.

#### LastRecordTime -- `int LastRecordTime`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

#### Map -- `const string Map`

The map UID

#### SortedPlayers_Race -- `const array<PlayerCpInfo> SortedPlayers_Race`

An array of `PlayerCpInfo`s sorted by most checkpoints to fewest.

#### SortedPlayers_TimeAttack -- `const array<PlayerCpInfo> SortedPlayers_TimeAttack`

An array of `PlayerCpInfo`s sorted by best time to worst time.

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.



## MLFeed::RankType (enum)

sort method for players

- `Race`
- `RaceRespawns`
- `TimeAttack`


## MLFeed::SharedGhostDataHook (class)

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### Ghosts -- `const array<MLFeed::GhostInfo> Ghosts`

*Deprecated, prefer .Ghosts_V2*; Array of GhostInfos

#### NbGhosts -- `uint NbGhosts`

Number of currently loaded ghosts

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### type -- `const string type`



## MLFeed::SharedGhostDataHook_V2 (class)

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

### Functions

#### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

#### OnEvent -- `void OnEvent(PendingEvent@ event)`

### Properties

#### Ghosts -- `const array<MLFeed::GhostInfo> Ghosts`

*Deprecated, prefer .Ghosts_V2*; Array of GhostInfos

#### Ghosts_V2 -- `const array<MLFeed::GhostInfo_V2> Ghosts_V2`

Array of GhostInfo_V2s

#### NbGhosts -- `uint NbGhosts`

Number of currently loaded ghosts

#### SourcePlugin -- `Meta::Plugin@ SourcePlugin`

#### type -- `const string type`



## MLFeed::SpawnStatus (enum)

The spawn status of a player.

- `NotSpawned`
- `Spawning`
- `Spawned`
