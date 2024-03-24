# MLFeed: Race Data

This plugin provides other plugins with data about the current race. You might need to install it to make other plugins work.

*Requires MLHook (you need to install that plugin too)*

**Please report performance issues!** See `boring stuff` below for who/where.

## For Developers

Currently exposed data:
* Sorted Player data
  * For each player: LatestCPTime, CPCount, Cached Previous CP Times, Spawn Status, Best Time, Best CP Times, Best Lap Times, Time Lost to Respawns (in total and per CP), NbRespawns, RoundPoints, Points, TeamNum, IsMVP, CurrentLap
  * Sort methods
    * `TimeAttack`: sort by best time
    * `Race`: sorted by race leader
    * `Race_Respawns`: sorted by race leader, but updates ranking immediately when a player respawns to account for time-loss
* Knockout data (for COTD / KO)
  * Per-Player Alive and DNF status
  * Total Rounds, Current Round, Alive Players, Number of KOs This Round, Next KO Milestone, Number of Players (originally)
* The last record set by the current player
* Ghost Data
  * Which ghosts have been loaded, the name of the ghost, and the ghost's checkpoint times.
* Matchmaking data
  * Clan (Team) Scores, current MVP, Players Finished, Points Limit, Points Repartition, Ranking mode, Round Number, Round Winning Clan, Start of round indicators, Team Populations, Teams Unbalanced flag, Warm Up flag
  * Points calculation given current points repartition and a finish order.

Additional data exposure available upon request.

### Using MLFeed: Race Data

Some plugins already using MLFeed:

- https://github.com/XertroV/tm-cotd-buffer-time/
- https://github.com/XertroV/tm-race-stats/
- https://github.com/XertroV/tm-list-players-pbs/

#### Importing to your plugin

Include this in your `info.toml` file:

```toml
[script]
dependencies = ["MLHook", "MLFeedRaceData"] # need both
```

see also: [https://openplanet.dev/docs/reference/info-toml](https://openplanet.dev/docs/reference/info-toml)

#### Usage: Getting started

*Note: it is recommended that you use the Openplanet VSCode extension which will provide autocompletion and documentation for you when using _MLFeed_.*

##### Main Entry Points

Several feeds are available that provide different information. The functions that provide the feeds are:

* `auto RaceData = MLFeed::GetRaceData_V4()`
* `auto KoData = MLFeed::GetKoData()`
* `auto GhostData = MLFeed::GetGhostData()`
* `auto TeamsData = MLFeed::GetTeamsMMData_V1()`

Full docs are below.

##### Upgrading to v0.4

See the upgrade guide: [https://github.com/XertroV/tm-mlfeed-race-data/blob/master/UPGRADE_v0.4.md](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/UPGRADE_v0.4.md)

##### Race Data Example

Main type: `HookRaceStatsEventsBase_V4`

Example usage: doing something on player respawn.

```AngelScript
uint lastRespawnCount = 0;

void Update(float dt) {
    if (GetApp().CurrentPlayground is null) return;
    // Get race data and the local player
    auto RaceData = MLFeed::GetRaceData_V4();
    auto player = RaceData.GetPlayer_V4(MLFeed::LocalPlayersName);
    if (player is null) return;
    // check for respawns
    if (player.NbRespawnsRequested != lastRespawnCount) {
        lastRespawnCount = player.NbRespawnsRequested;
        if (lastRespawnCount != 0) {
            startnew(OnPlayerRespawn);
        }
    }
}

void OnPlayerRespawn() {
    // do stuff
}
```

**Docs at end**

#### Usage: See Also

The Demo UIs available in (openplanet's) developer mode (via `Scripts` menu) & associated source code in [the repo](https://github.com/XertroV/tm-mlfeed-race-data).

[Exported functions (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)

[Exported classes (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)

[Example Usage - COTD Buffer Time](https://github.com/XertroV/tm-cotd-buffer-time/blob/57ee1bce5ccd115a0ebef2a9b23f72d77cbfa28a/src/KoBufferDisplay.as#L132-L133)

[Example Usage - Race Stats](https://github.com/XertroV/tm-race-stats/blob/master/src/Main.as)

[Example Optional Usage - List Players' PBs](https://github.com/XertroV/tm-list-players-pbs/blob/17a7afa6d80b235dfad93a5f4512ea57be82e432/src/Main.as#L237)

*Still curious about how to use something? Read the examples and use github search to find usages! Still not sure? Ask @XertroV on the Openplanet Discord*

## Boring Stuff

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-mlfeed-race-data](https://github.com/XertroV/tm-mlfeed-race-data)

GL HF

-------------

# `MLFeed::` Docs

The main exposed functions will get you the feeds.

Those then give you access data to each player/ghost.

Functions, properties, and types are exposed under the `MLFeed::` namespace.

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

### GetRaceData_V2 -- `const HookRaceStatsEventsBase_V2@ GetRaceData_V2()`
### GetRaceData_V3 -- `const HookRaceStatsEventsBase_V3@ GetRaceData_V3()`
### GetRaceData_V4 -- `const HookRaceStatsEventsBase_V4@ GetRaceData_V4()`

Exposes checkpoint data, spawn info, and lists of players for each sorting method.
You can call this function as often as you like.
Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)

### GetTeamsMMData_V1 -- `const HookTeamsMMEventsBase_V1@ GetTeamsMMData_V1()`

Object exposing info about the current Matchmaking Teams game.
Includes warm up, team points, when new rounds begin, current MVP, players finished, and points prediction.

## Properties

### GameTime -- `uint GameTime`

The current server's GameTime, or 0 if not in a server

### LocalPlayersName -- `const string LocalPlayersName`

returns the name of the local player, or an empty string if this is not yet known







## MLFeed::HookRaceStatsEventsBase_V3 (class)

The main class used to access race data.
It exposes 3 sorted lists of players, and general information about the map/race.

### Functions

#### GetPlayer_V2 -- `const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const`

#### GetPlayer_V3 -- `const PlayerCpInfo_V3@ GetPlayer_V3(const string &in name) const`
#### GetPlayer_V4 -- `const PlayerCpInfo_V4@ GetPlayer_V4(const string &in name) const`

Get a player's info

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

**Note:** cast to `PlayerCpInfo_V4` to access new properties.

#### SortedPlayers_Race_Respawns -- `const array<PlayerCpInfo_V2>@ SortedPlayers_Race_Respawns`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

**Note:** cast to `PlayerCpInfo_V4` to access new properties.

#### SortedPlayers_TimeAttack -- `const array<PlayerCpInfo_V2>@ SortedPlayers_TimeAttack`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

**Note:** cast to `PlayerCpInfo_V4` to access new properties.

#### SpawnCounter -- `uint SpawnCounter`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.









## MLFeed::PlayerCpInfo_V4 (class)

Each's players status in the race, with a focus on CP related info.

### Functions

#### FindCSmPlayer -- `CSmPlayer@ FindCSmPlayer()`

Return's the players CSmPlayer object if it is available, otherwise null. The full list of players is searched each time.

#### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, rr: 17, tr: 3, cp: 5 (0:43.231), Spawned, bt: 0:55.992)"

### Properties

#### BestLapTimes -- `const array<uint>@ BestLapTimes`

this player's CP times for their best lap this session

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

#### latencyEstimate -- `float latencyEstimate`

an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it




## MLFeed::SpawnStatus (enum)

The spawn status of a player.

- `NotSpawned`
- `Spawning`
- `Spawned`







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










## MLFeed::SharedGhostDataHook_V2 (class)

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

### Properties

#### Ghosts_V2 -- `const array<MLFeed::GhostInfo_V2> Ghosts_V2`

Array of GhostInfo_V2s

#### NbGhosts -- `uint NbGhosts`

Number of currently loaded ghosts



## MLFeed::GhostInfo_V2 (class)

Information about a currently loaded ghost.

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





## MLFeed::HookTeamsMMEventsBase_V1 (class)

Info about MM: game state, team points, player points (this round and total), current MVP

### Functions

#### ComputePoints -- `void ComputePoints(const int[]@ finishedTeamOrder, int[]@ points, int[]@ teamPoints) const`

Pass in a list of player.TeamNum for a finishing order, and 2 arrays that will be written to: the first will contain the points earned by each player for their team, the second contains the total points for each team (length 3).

Usage: `teamPoints[player.TeamNum]`

Implementation reference: `ComputeLatestRaceScores` in `Titles/Trackmania/Scripts/Libs/Nadeo/ModeLibs/TrackMania/Teams/TeamsCommon.Script.txt`

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

#### StartNewRace -- `int StartNewRace`

Increments each race as a flag to reset state. 0 during warmup. 1 during first round, etc.

#### TeamPopulations -- `array<int>@ TeamPopulations`

The number of players on each team. Length is always 31.

#### TeamsUnbalanced -- `bool TeamsUnbalanced`

Whether the populations of the teams is unequal.

#### WarmUpIsActive -- `bool WarmUpIsActive`

True when the warmup is active.
