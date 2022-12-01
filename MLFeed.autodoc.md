# NS: MLFeed

## Child Namespaces

* MLFeed::KoPlayerState
* MLFeed::HookKoStatsEventsBase
* MLFeed::KoDataProxy
* MLFeed::PlayerCpInfo
* MLFeed::PlayerCpInfo_V2
* MLFeed::HookRaceStatsEventsBase
* MLFeed::HookRaceStatsEventsBase_V2
* MLFeed::HookRecordEventsBase
* MLFeed::RaceDataProxy
* MLFeed::SharedGhostDataHook
* MLFeed::SharedGhostDataHook_V2
* MLFeed::GhostInfo
* MLFeed::GhostInfo_V2

## Functions

### GetGhostData -- `const SharedGhostDataHook_V2 GetGhostData()`

### GetGhostData -- `const SharedGhostDataHook_V2 GetGhostData()`

### GetKoData -- `const KoDataProxy GetKoData()`

### GetKoData -- `const KoDataProxy GetKoData()`

### GetPlayersBestTimes -- `const array<uint>@ GetPlayersBestTimes(const string &in playerName)`

### GetPlayersBestTimes -- `const array<uint>@ GetPlayersBestTimes(const string &in playerName)`

### GetRaceData -- `const RaceDataProxy GetRaceData()`

### GetRaceData -- `const RaceDataProxy GetRaceData()`

### GetRaceData_V2 -- `const HookRaceStatsEventsBase_V2 GetRaceData_V2()`

### GetRaceData_V2 -- `const HookRaceStatsEventsBase_V2 GetRaceData_V2()`

### GhostInfo -- `GhostInfo@ GhostInfo(const MLHook::PendingEvent@ &in event)`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

### GhostInfo_V2 -- `GhostInfo_V2@ GhostInfo_V2(const MLHook::PendingEvent@ &in event)`

### HookKoStatsEventsBase -- `HookKoStatsEventsBase@ HookKoStatsEventsBase(const string &in type)`

### HookRaceStatsEventsBase -- `HookRaceStatsEventsBase@ HookRaceStatsEventsBase(const string &in type)`

### HookRaceStatsEventsBase_V2 -- `HookRaceStatsEventsBase_V2@ HookRaceStatsEventsBase_V2(const string &in type)`

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

### PlayerCpInfo_V2 -- `PlayerCpInfo_V2@ PlayerCpInfo_V2(PlayerCpInfo_V2@ _from, int cpOffset)`

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

### get_GameTime -- `uint get_GameTime() property`

The current server's GameTime

### get_LocalPlayersName -- `const string get_LocalPlayersName() property`

returns the name of the local player, or an empty string if this is not yet known



## Types/Classes

### `enum Dir`



### `class GhostInfo`

Information about a currently loaded ghost.
Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`

#### Functions

##### get_Checkpoints -- `const array<uint>@ get_Checkpoints() const property`

Ghost.Result.Checkpoints

##### get_IdName -- `const string get_IdName() const property`

Ghost.IdName

##### get_IdUint -- `uint get_IdUint() const property`

Should be equiv to Ghost.Id.Value (experimental)

##### get_Nickname -- `const string get_Nickname() const property`

Ghost.Nickname

##### get_Result_Score -- `int get_Result_Score() const property`

Ghost.Result.Score

##### get_Result_Time -- `int get_Result_Time() const property`

Ghost.Result.Time

##### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

#### Properties

##### `private array<uint> _Checkpoints`

##### `private string _IdName`

##### `private uint _IdUint`

##### `private string _Nickname`

##### `private int _Result_Score`

##### `private int _Result_Time`



### `class GhostInfo_V2`

#### Functions

##### get_Checkpoints -- `const array<uint>@ get_Checkpoints() const property`

Ghost.Result.Checkpoints

##### get_IdName -- `const string get_IdName() const property`

Ghost.IdName

##### get_IdUint -- `uint get_IdUint() const property`

Should be equiv to Ghost.Id.Value (experimental)

##### get_Nickname -- `const string get_Nickname() const property`

Ghost.Nickname

##### get_Result_Score -- `int get_Result_Score() const property`

Ghost.Result.Score

##### get_Result_Time -- `int get_Result_Time() const property`

Ghost.Result.Time

##### opEquals -- `bool opEquals(const GhostInfo@ &in other) const`

##### super -- `void super(const MLHook::PendingEvent&in event)`

Call constructor of parent class: GhostInfo

#### Properties

##### `bool IsLocalPlayer`

##### `bool IsPersonalBest`

##### `private array<uint> _Checkpoints`

##### `private string _IdName`

##### `private uint _IdUint`

##### `private string _Nickname`

##### `private int _Result_Score`

##### `private int _Result_Time`



### `class HookKoStatsEventsBase`

#### Functions

##### GetPlayerState -- `KoPlayerState GetPlayerState(const string &in name)`

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get_type -- `const string get_type() property`

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`

##### `int division`

##### `int kosMilestone`

##### `int kosNumber`

##### `string lastGM`

##### `string lastMap`

##### `int mapRoundNb`

ServerNumber

##### `int mapRoundTotal`

##### `dictionary playerStates`

##### `array<string> players`

##### `int playersNb`

##### `int roundNb`

##### `int roundTotal`



### `class HookRaceStatsEventsBase`

#### Functions

##### GetPlayer -- `PlayerCpInfo GetPlayer(const string &in name)`

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### get_CPsToFinish -- `uint get_CPsToFinish() const property`

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get_type -- `const string get_type() property`

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `uint CpCount`

##### `uint LapCount`

##### `uint SpawnCounter`

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`

##### `string lastMap`

##### `dictionary latestPlayerStats`

##### `array<PlayerCpInfo> sortedPlayers_Race`

##### `array<PlayerCpInfo> sortedPlayers_TimeAttack`



### `class HookRaceStatsEventsBase_V2`

#### Functions

##### GetPlayer -- `PlayerCpInfo GetPlayer(const string &in name)`

##### GetPlayer_V2 -- `const PlayerCpInfo_V2 GetPlayer_V2(const string &in name) const`

Get a player's info

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### _GetPlayer_V2 -- `PlayerCpInfo_V2 _GetPlayer_V2(const string &in name)`

##### get_CPCount -- `uint get_CPCount() const property`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

##### get_CPsToFinish -- `uint get_CPsToFinish() const property`

##### get_Map -- `const string get_Map() property`

The map UID

##### get_SortedPlayers_Race -- `const array<PlayerCpInfo_V2>@ get_SortedPlayers_Race() const property`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest.

##### get_SortedPlayers_Race_Respawns -- `const array<PlayerCpInfo_V2>@ get_SortedPlayers_Race_Respawns() const property`

An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns.

##### get_SortedPlayers_TimeAttack -- `const array<PlayerCpInfo_V2>@ get_SortedPlayers_TimeAttack() const property`

An array of `PlayerCpInfo_V2`s sorted by best time to worst time.

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get__SortedPlayers_Race -- `array<PlayerCpInfo_V2>@ get__SortedPlayers_Race() property`

##### get__SortedPlayers_Race_Respawns -- `array<PlayerCpInfo_V2>@ get__SortedPlayers_Race_Respawns() property`

##### get__SortedPlayers_TimeAttack -- `array<PlayerCpInfo_V2>@ get__SortedPlayers_TimeAttack() property`

##### get_type -- `const string get_type() property`

##### super -- `void super(const string&in type)`

Call constructor of parent class: HookRaceStatsEventsBase

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `uint CpCount`

##### `uint LapCount`

##### `uint SpawnCounter`

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`

##### `string lastMap`

##### `dictionary latestPlayerStats`

##### `array<PlayerCpInfo> sortedPlayers_Race`

##### `array<PlayerCpInfo> sortedPlayers_TimeAttack`

##### `protected array<PlayerCpInfo_V2> v2_sortedPlayers_Race`

##### `protected array<PlayerCpInfo_V2> v2_sortedPlayers_Race_Respawns`

##### `protected array<PlayerCpInfo_V2> v2_sortedPlayers_TimeAttack`



### `class HookRecordEventsBase`

#### Functions

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### get_LastRecordTime -- `int get_LastRecordTime() const property`

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get_type -- `const string get_type() property`

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `protected int _lastRecordTime`

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`



### `class KoDataProxy`

Main source of information about KO rounds.
Proxy for the internal type `KoFeed::HookKoStatsEvents`.

#### Functions

##### GetPlayerState -- `const KoPlayerState GetPlayerState(const string &in name) const`

Get a player's MLFeed::KoPlayerState.
It has only 3 properties: `name`, `isAlive`, and `isDNF`.

##### get_Division -- `int get_Division() const property`

The current division number. *(Note: possibly inaccurate. Use with caution.)*

##### get_GameMode -- `const string get_GameMode() const property`

The current game mode, e.g., `TM_KnockoutDaily_Online`, or `TM_TimeAttack_Online`, etc.

##### get_KOsMilestone -- `int get_KOsMilestone() const property`

KOs per round will change when the number of players is <= KOsMilestone.

##### get_KOsNumber -- `int get_KOsNumber() const property`

KOs per round.

##### get_Map -- `const string get_Map() const property`

The current map UID

##### get_MapRoundNb -- `int get_MapRoundNb() const property`

The current round number for this map.

##### get_MapRoundTotal -- `int get_MapRoundTotal() const property`

The total number of rounds for this map.

##### get_Players -- `const array<string> get_Players() const property`

A `string[]` of player names. It includes all players in the KO round, even if they've left.

##### get_PlayersNb -- `int get_PlayersNb() const property`

The number of players participating.

##### get_RoundNb -- `int get_RoundNb() const property`

The round number over all maps. (I think)

##### get_RoundTotal -- `int get_RoundTotal() const property`

The total number of rounds over all maps. (I think)

#### Properties

##### `private HookKoStatsEventsBase hook`



### `class KoPlayerState`

A player's state in a KO match



#### Properties

##### `bool isAlive`

Whether the player is still 'in'; `false` implies they have been knocked out.

##### `bool isDNF`

Whether the player DNF'd or not. This is set to false the round after that player DNFs.

##### `string name`

The player's name.



### `class PlayerCpInfo`

Each's players status in the race, with a focus on CP related info.

#### Functions

##### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"

##### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex)`

##### get_IsSpawned -- `bool get_IsSpawned() property`

Whether the player is spawned

#### Properties

##### `int bestTime`

The player's best time this session

##### `int cpCount`

How many CPs that player currently has

##### `array<int> cpTimes`

The times of each of their CPs since respawning

##### `int lastCpTime`

Their last CP time as on their chronometer

##### `string name`

The player's name

##### `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

##### `uint spawnIndex`

The spawn index when the player spawned

##### `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

##### `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)



### `class PlayerCpInfo_V2`

#### Functions

##### ModifyRank -- `void ModifyRank(Dir dir, RankType rt)`

##### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, rr: 17, tr: 3, cp: 5 (0:43.231), Spawned, bt: 0:55.992)"

##### ToString -- `string ToString() const`

Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"

##### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex, bool callSuper)`

##### UpdateFrom -- `void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex)`

##### get_BestTime -- `int get_BestTime() const property`

The player's best time this session

##### get_CpCount -- `int get_CpCount() const property`

How many CPs that player currently has

##### get_CpTimes -- `const array<int>@ get_CpTimes() const property`

The times of each of their CPs since respawning

##### get_CurrentRaceTime -- `int get_CurrentRaceTime() const property`

This player's CurrentRaceTime with latency taken into account

##### get_CurrentRaceTimeRaw -- `int get_CurrentRaceTimeRaw() const property`

This player's CurrentRaceTime without accounting for latency

##### get_IsSpawned -- `bool get_IsSpawned() property`

Whether the player is spawned

##### get_LastCpOrRespawnTime -- `int get_LastCpOrRespawnTime() const property`

Player's last CP time _OR_ their last respawn time if it is greater

##### get_LastCpTime -- `int get_LastCpTime() const property`

Player's last CP time

##### get_LastTheoreticalCpTime -- `int get_LastTheoreticalCpTime() const property`

get the last CP time of the player minus time lost to respawns

##### get_Name -- `const string get_Name() const property`

The player's name

##### get_RaceRank -- `uint get_RaceRank() const property`

The player's rank as measured in a race (when all players would spawn at the same time).

##### get_RaceRespawnRank -- `uint get_RaceRespawnRank() const property`

The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.

##### get_SpawnIndex -- `uint get_SpawnIndex() const property`

The spawn index when the player spawned

##### get_SpawnStatus -- `SpawnStatus get_SpawnStatus() const property`

The players's spawn status: NotSpawned, Spawning, or Spawned

##### get_TaRank -- `uint get_TaRank() const property`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

##### get_TheoreticalRaceTime -- `int get_TheoreticalRaceTime() const property`

##### get_TimeLostToRespawnByCp -- `const array<int>@ get_TimeLostToRespawnByCp() const property`

The times of each of their CPs since respawning

##### super -- `void super(PlayerCpInfo@ _from, int cpOffset)`

Call constructor of parent class: PlayerCpInfo

##### super -- `void super(MLHook::PendingEvent@ event, uint _spawnIndex)`

Call constructor of parent class: PlayerCpInfo

#### Properties

##### `const array<uint>@ BestRaceTimes`

this player's CP times for their best performance this session (since the map loaded)

##### `bool IsLocalPlayer`

whether this player corresponds to the physical player playing the game

##### `uint LastRespawnCheckpoint`

the last checkpoint that the player respawned at

##### `uint LastRespawnRaceTime`

the last time this player respawned (measure against CurrentRaceTime)

##### `uint NbRespawnsRequested`

number of times the player has respawned

##### `uint StartTime`

when the player spawned (measured against GameTime)

##### `uint TimeLostToRespawns`

the amount of time the player has lost due to respawns

##### `int bestTime`

The player's best time this session

##### `int cpCount`

How many CPs that player currently has

##### `array<int> cpTimes`

The times of each of their CPs since respawning

##### `protected array<int> cpTimesRaw`

protected int LastCpOrRespawnTime;

##### `float lagDataPoints`

##### `int lastCpTime`

Their last CP time as on their chronometer

##### `protected int lastCpTimeRaw`

##### `float latencyEstimate`

##### `string name`

The player's name

##### `uint raceRank`

The player's rank as measured in a race (when all players would spawn at the same time).

##### `int raceRespawnRank`

##### `uint spawnIndex`

The spawn index when the player spawned

##### `SpawnStatus spawnStatus`

The players's spawn status: NotSpawned, Spawning, or Spawned

##### `uint taRank`

The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)

##### `protected array<int> timeLostToRespawnsByCp`



### `class RaceDataProxy`

Provides race data.
It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`.

#### Functions

##### GetPlayer -- `const PlayerCpInfo GetPlayer(const string &in name) const`

Get a player by name (see `.SortedPlayers_Race/TimeAttack` for players)

##### get_CPCount -- `uint get_CPCount() const property`

The number of checkpoints each lap.
Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.

##### get_CPsToFinish -- `uint get_CPsToFinish() const property`

The number of waypoints a player needs to hit to finish the race.
In single lap races, this is 1 more than `.CPCount`.

##### get_LapCount -- `uint get_LapCount() const property`

The number of laps for this map.

##### get_LastRecordTime -- `int get_LastRecordTime() const property`

When the player sets a new personal best, this is set to that time.
Reset to -1 at the start of each map.
Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`

##### get_Map -- `const string get_Map() const property`

The map UID

##### get_SortedPlayers_Race -- `const array<PlayerCpInfo> get_SortedPlayers_Race() const property`

An array of `PlayerCpInfo`s sorted by most checkpoints to fewest.

##### get_SortedPlayers_TimeAttack -- `const array<PlayerCpInfo> get_SortedPlayers_TimeAttack() const property`

An array of `PlayerCpInfo`s sorted by best time to worst time.

##### get_SpawnCounter -- `uint get_SpawnCounter() const property`

This increments by 1 each frame a player spawns.
When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
This is useful for some sorting methods.
This value is set to 0 on plugin load and never reset.

#### Properties

##### `private HookRaceStatsEventsBase hook`

##### `private HookRecordEventsBase recHook`



### `enum RankType`



### `class SharedGhostDataHook`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.

#### Functions

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### get_Ghosts -- `const array<MLFeed::GhostInfo> get_Ghosts() const property`

Array of GhostInfos

##### get_NbGhosts -- `uint get_NbGhosts() const property`

Number of currently loaded ghosts

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get_type -- `const string get_type() property`

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`



### `class SharedGhostDataHook_V2`

Provides access to ghost info.
This includes record ghosts loaded through the UI, and personal best ghosts.
When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
Therefore, duplicate ghost infos may be recorded.
V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.

#### Functions

##### NotifyMLHookError -- `void NotifyMLHookError(const string &in msg)`

##### OnEvent -- `void OnEvent(PendingEvent@ event)`

}

##### get_Ghosts -- `const array<MLFeed::GhostInfo> get_Ghosts() const property`

Array of GhostInfos

##### get_Ghosts_V2 -- `const array<MLFeed::GhostInfo_V2> get_Ghosts_V2() const property`

Array of GhostInfo_V2s

##### get_NbGhosts -- `uint get_NbGhosts() const property`

Number of currently loaded ghosts

##### get_SourcePlugin -- `Meta::Plugin get_SourcePlugin() property`

##### get_type -- `const string get_type() property`

##### super -- `void super(const string&in type)`

Call constructor of parent class: SharedGhostDataHook

##### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType

#### Properties

##### `private Meta::Plugin _sourcePlugin`

##### `private string _type`



### `enum SpawnStatus`

The spawn status of a player.





----------

# NS: MLFeed::KoPlayerState












----------

# NS: MLFeed::HookKoStatsEventsBase



## Functions

### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType








----------

# NS: MLFeed::KoDataProxy












----------

# NS: MLFeed::PlayerCpInfo












----------

# NS: MLFeed::PlayerCpInfo_V2



## Functions

### super -- `void super(PlayerCpInfo@ _from, int cpOffset)`

Call constructor of parent class: PlayerCpInfo

### super -- `void super(MLHook::PendingEvent@ event, uint _spawnIndex)`

Call constructor of parent class: PlayerCpInfo








----------

# NS: MLFeed::HookRaceStatsEventsBase



## Functions

### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType








----------

# NS: MLFeed::HookRaceStatsEventsBase_V2



## Functions

### super -- `void super(const string&in type)`

Call constructor of parent class: HookRaceStatsEventsBase








----------

# NS: MLFeed::HookRecordEventsBase



## Functions

### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType








----------

# NS: MLFeed::RaceDataProxy












----------

# NS: MLFeed::SharedGhostDataHook



## Functions

### super -- `void super()`

Call constructor of parent class: MLHook::HookMLEventsByType








----------

# NS: MLFeed::SharedGhostDataHook_V2



## Functions

### super -- `void super(const string&in type)`

Call constructor of parent class: SharedGhostDataHook








----------

# NS: MLFeed::GhostInfo












----------

# NS: MLFeed::GhostInfo_V2



## Functions

### super -- `void super(const MLHook::PendingEvent&in event)`

Call constructor of parent class: GhostInfo
