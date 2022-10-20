# MLFeed: Race Data

This plugin provides other plugins with data about the current race. You might need to install it to make other plugins work.

*Requires MLHook (you need to install that plugin too)*

## For Developers

Currently exposed data:
* Sorted Player data
    * For each player: LatestCPTime, CPCount, Cached Previous CP Times, Spawn Status, Best Time
    * Sort methods: TimeAttack (sort by best time), Race (sorted by race leader)
* Knockout data (for COTD / KO)
  * Per-Player Alive and DNF status
    * Total Rounds, Current Round, Alive Players, Number of KOs This Round, Next KO Milestone, Number of Players (originally)
* The last record set by the current player

Additional data exposure available upon request.

### Using MLFeed: Race Data

Example plugins:

- https://github.com/XertroV/tm-cotd-buffer-time
- https://github.com/XertroV/tm-race-stats/

#### Importing to your plugin

Include this in your `info.toml` file:

```toml
[script]
dependencies = ["MLHook", "MLFeedRaceData"] # need both
```

see also: [https://openplanet.dev/docs/reference/info-toml](https://openplanet.dev/docs/reference/info-toml)

#### Usage: Getting started

```angelscript
void Main() {
    /**
     * Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    MLFeed::RaceDataProxy@ RaceData = MLFeed::GetRaceData();
    /**
     * Your plugin's `KoDataProxy@` that exposes KO round information, and each player's , spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    MLFeed::KoDataProxy@ KoData = MLFeed::GetKoData();
}
```

#### Usage: Available data / information

```AngelScript
namespace MLFeed {
    /* Provides race data.
       It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`. */
    interface RaceDataProxy {
        /* Get a player by name (see `.SortedPlayers_Race/TimeAttack` for players) */
        const PlayerCpInfo@ GetPlayer(const string &in name);

        /* The map UID */
        const string get_Map();

        /* An array of `PlayerCpInfo`s sorted by most checkpoints to fewest. */
        const array<PlayerCpInfo@> get_SortedPlayers_Race();

        /* An array of `PlayerCpInfo`s sorted by best time to worst time. */
        const array<PlayerCpInfo@> get_SortedPlayers_TimeAttack();

        /* The number of checkpoints each lap.
           Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted. */
        uint get_CPCount();

        /* The number of laps for this map. */
        uint get_LapCount();

        /* The number of waypoints a player needs to hit to finish the race.
           In single lap races, this is 1 more than `.CPCount`. */
        uint get_CPsToFinish();

        /* This increments by 1 each frame a player spawns.
           When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
           This is useful for some sorting methods.
           This value is set to 0 on plugin load and never reset. */
        uint get_SpawnCounter();

        /* When the player sets a new personal best, this is set to that time.
           Reset to -1 at the start of each map.
           Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();` */
        int get_LastRecordTime();
    }

    /* Each's players status in the race, with a focus on CP related info. */
    interface PlayerCpInfo {
        // The player's name
        string name;

        // How many CPs that player currently has
        int cpCount;

        // Their last CP time as on their chronometer
        int lastCpTime;

        // The times of each of their CPs since respawning
        int[] cpTimes;

        // The player's best time this session
        int bestTime;

        // The players's spawn status: NotSpawned, Spawning, or Spawned
        MLFeed::SpawnStatus spawnStatus;

        // The spawn index when the player spawned
        uint spawnIndex = 0;

        // The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)
        uint taRank = 0;  // set by hook; not sure if we can get it from ML

        // The player's rank as measured in a race (when all players would spawn at the same time).
        uint raceRank = 0;  // set by hook; not sure if we can get it from ML

        // Whether the player is spawned
        bool get_IsSpawned();

        // Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"
        string ToString() const {
            string[] inner = {name, ''+cpCount, ''+lastCpTime, ''+spawnStatus, ''+raceRank, ''+taRank, ''+bestTime};
            return "PlayerCpInfo(" + string::Join(inner, ", ") + ")";
        }
    }

    /* The spawn status of a player. */
    enum SpawnStatus {
        NotSpawned = 0,
        Spawning = 1,
        Spawned = 2
    }


    /* Main source of information about KO rounds.
       Proxy for the internal type `KoFeed::HookKoStatsEvents`. */
    interface KoDataProxy {
        /* Get a player's MLFeed::KoPlayerState.
           It has only 3 properties: `name`, `isAlive`, and `isDNF`. */
        const KoPlayerState@ GetPlayerState(const string &in name);

        /* The current map UID */
        const string get_Map();

        /* The current game mode, e.g., `TM_KnockoutDaily_Online`, or `TM_TimeAttack_Online`, etc. */
        const string get_GameMode();

        /* A `string[]` of player names. It includes all players in the KO round, even if they've left. */
        const string[] get_Players();

        /* The current division number. *(Note: possibly inaccurate. Use with caution.)* */
        int get_Division();

        /* The current round number for this map. */
        int get_MapRoundNb();

        /* The total number of rounds for this map. */
        int get_MapRoundTotal();

        /* The round number over all maps. (I think) */
        int get_RoundNb();

        /* The total number of rounds over all maps. (I think) */
        int get_RoundTotal();

        /* The number of players participating. */
        int get_PlayersNb();

        /* KOs per round will change when the number of players is <= KOsMilestone. */
        int get_KOsMilestone();

        /* KOs per round. */
        int get_KOsNumber();
    }

    /* A player's state in a KO match */
    interface KoPlayerState {
        // The player's name.
        string name;

        // Whether the player is still 'in'; `false` implies they have been knocked out.
        bool isAlive = true;

        // Whether the player DNF'd or not. This is set to false the round after that player DNFs.
        bool isDNF = false;
    }
}
```

#### Usage: See Also

[Exported functions (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)

[Exported classes (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)

[Example Usage](https://github.com/XertroV/tm-cotd-buffer-time/blob/57ee1bce5ccd115a0ebef2a9b23f72d77cbfa28a/src/KoBufferDisplay.as#L132-L133)

*Still curious about how to use something? Read the examples and use github search to find usages! Still not sure? Ask @XertroV on the Openplanet Discord*

## Boring Stuff

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-mlfeed-race-data](https://github.com/XertroV/tm-mlfeed-race-data)

GL HF

-----

todo:

* look into teams data, e.g. during ranked modes
