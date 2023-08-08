namespace MLFeed {
    /* A player's state in a KO match */
    shared class KoPlayerState {
        // The player's name.
        string name;
        // Whether the player is still 'in'; `false` implies they have been knocked out.
        bool isAlive = true;
        /* Whether the player DNF'd or not. This is set to false the round after that player DNFs. */
        bool isDNF = false;
        KoPlayerState(const string &in n) {
            name = n;
        }
        KoPlayerState(const string &in n, bool alive, bool dnf) {
            name = n;
            isAlive = alive;
            isDNF = dnf;
        }
    }

    /**
     * Info about MM: game state, team points, player points (this round and total), current MVP
     */
    shared class HookTeamsMMEventsBase_V1 : MLHook::HookMLEventsByType {
        // Increments each race as a flag to reset state. 0 during warmup. 1 during first round, etc.
        int StartNewRace = -123;
        // True when the warmup is active.
        bool WarmUpIsActive;
        // Ranking mode used. 0 = BestRace, 1 = CurrentRace. (MM uses 1)
        int RankingMode = -1;
        // Rounds won by team. Updated each round as soon as the last player despawns. Blue at index 1, Red at index 2. Length: 31.
        array<int>@ ClanScores;
        // Current MVP's account id. Updated with scores.
        string MvpAccountId;
        // Current MVP's name. Updated with scores.
        string MvpName;
        // Player logins in finishing order. Updated when a player finishes and at the start of the race.
        array<string>@ PlayersFinishedLogins;
        // Player names in finishing order. Updated when a player finishes and at the start of the race.
        array<string>@ PlayersFinishedNames;
        // The last game time that a player finished and the corresponding lists were updated.
        int PlayerFinishedRaceUpdate = -123;
        // The points available for each position, set after warmup and updated at the start of the next race (after a player leaves).
        array<int>@ PointsRepartition;
        // set to -1 on race start, and set to 1 or 2 at end of race indicating the winning team. 0 = draw.
        int RoundWinningClan;
        // The current round. Incremented at the completion of each round. (RoundNumber will end +1 more than StartNewRace.)
        int RoundNumber;
        // A team wins when they reach this many points. Set after warmup.
        int PointsLimit;
        // Whether the populations of the teams is unequal.
        bool TeamsUnbalanced = false;
        // The number of players on each team. Length is always 31.
        int[]@ TeamPopulations;

        HookTeamsMMEventsBase_V1(const string &in type) {
            super(type);
        }

        /**
         * Pass in a list of player.TeamNum for a finishing order, and 2 arrays that will be written to: the first will contain the points earned by each player for their team, the second contains the total points for each team (length 3).
         *
         * Usage: teamPoints[player.TeamNum]
         *
         * Implementation reference: `ComputeLatestRaceScores` in `Titles/Trackmania/Scripts/Libs/Nadeo/ModeLibs/TrackMania/Teams/TeamsCommon.Script.txt`
         */
        void ComputePoints(const int[]@ finishedTeamOrder, int[]@ points, int[]@ teamPoints, int &out winningTeam) const { throw("implemented elsewhere"); }
        // int[]@ ComputePoints(int[]@ finishedTeamOrder) const { throw("implemented elsewhere"); return null; }
    }

    shared class HookKoStatsEventsBase : MLHook::HookMLEventsByType {
        HookKoStatsEventsBase(const string &in type) {
            super(type);
        }

        string lastGM;
        string lastMap;
        string[] players;

        // ServerNumber
        int division = -1;
        int mapRoundNb = -1;
        int mapRoundTotal = -1;
        int roundNb = -1;
        int roundTotal = -1;
        int playersNb = -1;
        int kosMilestone = -1;
        int kosNumber = -1;
        dictionary playerStates;

        KoPlayerState@ GetPlayerState(const string &in name) {
            return cast<KoPlayerState>(playerStates[name]);
        }
    }

    /* Main source of information about KO rounds.
       Proxy for the internal type `KoFeed::HookKoStatsEvents`. */
    shared class KoDataProxy {
        private HookKoStatsEventsBase@ hook;
        KoDataProxy(HookKoStatsEventsBase@ h) {
            @hook = h;
        }
        /* Get a player's MLFeed::KoPlayerState.
           It has only 3 properties: `name`, `isAlive`, and `isDNF`.
        */
        const KoPlayerState@ GetPlayerState(const string &in name) const {
            return hook.GetPlayerState(name);
        }
        /* The current map UID */
        const string get_Map() const {
            return hook.lastMap;
        }
        /* The current game mode, e.g., `TM_KnockoutDaily_Online`, or `TM_TimeAttack_Online`, etc. */
        const string get_GameMode() const {
            return hook.lastGM;
        }
        /* A `string[]` of player names. It includes all players in the KO round, even if they've left. */
        const string[] get_Players() const {
            return hook.players;
        }
        /* The current division number. *(Note: possibly inaccurate. Use with caution.)* */
        int get_Division() const {
            return hook.division;
        }
        /* The current round number for this map. */
        int get_MapRoundNb() const {
            return hook.mapRoundNb;
        }
        /* The total number of rounds for this map. */
        int get_MapRoundTotal() const {
            return hook.mapRoundTotal;
        }
        /* The round number over all maps. (I think) */
        int get_RoundNb() const {
            return hook.roundNb;
        }
        /* The total number of rounds over all maps. (I think) */
        int get_RoundTotal() const {
            return hook.roundTotal;
        }
        /* The number of players participating. */
        int get_PlayersNb() const {
            return hook.playersNb;
        }
        /* KOs per round will change when the number of players is <= KOsMilestone. */
        int get_KOsMilestone() const {
            return hook.kosMilestone;
        }
        /* KOs per round. */
        int get_KOsNumber() const {
            return hook.kosNumber;
        }
    }

    /* The spawn status of a player. */
    shared enum SpawnStatus {
        NotSpawned = 0,
        Spawning = 1,
        Spawned = 2
    }

    /* Each's players status in the race, with a focus on CP related info. */
    shared class PlayerCpInfo {
        // The player's name
        string name;
        // How many CPs that player currently has
        int cpCount;
        // Their last CP time as on their chronometer
        int lastCpTime;
        // The CP times of that player (including the 0th cp at the 0th index; which will always be 0)
        int[] cpTimes;
        // The player's best time this session
        int bestTime;
        // The players's spawn status: NotSpawned, Spawning, or Spawned
        SpawnStatus spawnStatus;
        // The spawn index when the player spawned
        uint spawnIndex = 0;
        // The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)
        uint taRank = 0;  // set by hook; not sure if we can get it from ML
        // The player's rank as measured in a race (when all players would spawn at the same time).
        uint raceRank = 0;  // set by hook; not sure if we can get it from ML

        PlayerCpInfo(MLHook::PendingEvent@ event, uint _spawnIndex) {
            name = event.data[0]; // set once only
            cpTimes.InsertLast(0); // zeroth cpTime always 0
            UpdateFrom(event, _spawnIndex);
        }
        // create from another instance, useful for testing
        PlayerCpInfo(PlayerCpInfo@ _from, int cpOffset = 0) {
            cpOffset = Math::Min(cpOffset, 0); // so cpOffset <= 0
            int cpSetTo = Math::Max(_from.cpCount + cpOffset, 0);
            name = _from.name;
            cpCount = cpSetTo;
            cpTimes = _from.cpTimes;
            cpTimes.Resize(cpCount + 1);
            lastCpTime = cpTimes[cpCount];
            bestTime = _from.bestTime;
            spawnStatus = _from.spawnStatus;
        }

        void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex) {
            spawnIndex = _spawnIndex;
            if (event.data.Length < 5) {
                warn('PlayerCpInfo event.data had insufficient length');
                return;
            }
            cpCount = Text::ParseInt(event.data[1]);
            lastCpTime = Text::ParseInt(event.data[2]);
            cpTimes.Resize(cpCount + 1);
            if (cpCount > 0) {
                cpTimes[cpCount] = lastCpTime;
            }
            bestTime = Text::ParseInt(event.data[3]);
            spawnStatus = SpawnStatus(Text::ParseInt(event.data[4]));
        }

        // Whether the player is spawned
        bool get_IsSpawned() {
            return spawnStatus == SpawnStatus::Spawned;
        }

        // Formatted as: "PlayerCpInfo(name, cpCount, lastCpTime, spawnStatus, raceRank, taRank, bestTime)"
        string ToString() const {
            string[] inner = {name, ''+cpCount, ''+lastCpTime, ''+spawnStatus, ''+raceRank, ''+taRank, ''+bestTime};
            return "PlayerCpInfo(" + string::Join(inner, ", ") + ")";
        }
    }

    /* Each's players status in the race, with a focus on CP related info. */
    shared class PlayerCpInfo_V2 : PlayerCpInfo {
        protected int lastCpTimeRaw;
        // protected int LastCpOrRespawnTime;
        protected array<int> cpTimesRaw;
        protected array<int> timeLostToRespawnsByCp;
        int raceRespawnRank;

        PlayerCpInfo_V2(MLHook::PendingEvent@ event, uint _spawnIndex) {
            super(event, _spawnIndex);
            UpdateFrom(event, _spawnIndex, false);
            IsLocalPlayer = this.Name == MLFeed::LocalPlayersName;
        }
        PlayerCpInfo_V2(PlayerCpInfo_V2@ _from, int cpOffset) {
            super(_from, cpOffset);
            IsLocalPlayer = _from.IsLocalPlayer;
            NbRespawnsRequested = _from.NbRespawnsRequested;
            StartTime = _from.StartTime;
            @BestRaceTimes = _from.BestRaceTimes;
        }

        // The player's name
        const string get_Name() const { return name; }
        // How many CPs that player currently has
        int get_CpCount() const { return cpCount; }
        // Player's last CP time as on their chronometer
        int get_LastCpTime() const { return lastCpTime; }
        // Player's last CP time _OR_ their last respawn time if it is greater
        int get_LastCpOrRespawnTime() const { return Math::Max(lastCpTime, LastRespawnRaceTime); }
        // The CP times of that player (including the 0th cp at the 0th index; which will always be 0)
        const int[]@ get_CpTimes() const { return cpTimes; }
        // The time lost due to respawning at each CP
        const int[]@ get_TimeLostToRespawnByCp() const { return timeLostToRespawnsByCp; }
        // get the last CP time of the player minus time lost to respawns
        int get_LastTheoreticalCpTime() const {
            uint tl = 0;
            for (uint i = 0; i < TimeLostToRespawnByCp.Length - 1; i++) {
                tl += TimeLostToRespawnByCp[i];
            }
            return LastCpTime - tl;
        }
        // get the current race time of this player minus time lost to respawns
        int get_TheoreticalRaceTime() const {
            return CurrentRaceTime - TimeLostToRespawns;
        }
        // The player's best time this session
        int get_BestTime() const { return bestTime; }
        // The players's spawn status: NotSpawned, Spawning, or Spawned
        SpawnStatus get_SpawnStatus() const { return spawnStatus; }
        // The spawn index when the player spawned
        uint get_SpawnIndex() const { return spawnIndex; }
        // The player's rank as measured in Time Attack (one more than their index in `RaceData.SortedPlayers_TimeAttack`)
        uint get_TaRank() const { return taRank; }
        // The player's rank as measured in a race (when all players would spawn at the same time).
        uint get_RaceRank() const { return raceRank; }
        // The player's rank as measured in a race (when all players would spawn at the same time), accounting for respawns.
        uint get_RaceRespawnRank() const { return raceRespawnRank; }

        // this player's CP times for their best performance this session (since the map loaded). Can be null. Can be partial before a player has finished a complete run.
        const array<uint>@ BestRaceTimes = {};
        // whether this player corresponds to the physical player playing the game
        bool IsLocalPlayer;
        // when the player spawned (measured against GameTime)
        uint StartTime;

        // This player's CurrentRaceTime without accounting for latency
        int get_CurrentRaceTimeRaw() const {
            return int(GameTime) - int(StartTime);
        }
        // This player's CurrentRaceTime with latency taken into account
        int get_CurrentRaceTime() const {
            return CurrentRaceTimeRaw - int(latencyEstimate);
        }
        // number of times the player has respawned
        uint NbRespawnsRequested;
        // the last time this player respawned (measure against CurrentRaceTime)
        uint LastRespawnRaceTime;
        // the last checkpoint that the player respawned at
        uint LastRespawnCheckpoint;
        // the amount of time the player has lost due to respawns in total since the start of their current race/attempt
        uint TimeLostToRespawns;

        // an estimate of the latency in ms between when a player passes a checkpoint and when we learn about it
        float latencyEstimate = 0.;
        float lagDataPoints = 0;

        // internal use
        void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex, bool callSuper) {
            throw("Implemented in RaceFeed::_PlayerCpInfo_V2");
        }

        // internal use
        void ModifyRank(Dir dir, RankType rt) {
            if (rt == RankType::Race) {
                raceRank += int(dir);
            } else if (rt == RankType::RaceRespawns) {
                raceRespawnRank += int(dir);
            } else {
                taRank += int(dir);
            }
        }

        // Formatted as: "PlayerCpInfo(name, rr: 17, tr: 3, cp: 5 (0:43.231), Spawned, bt: 0:55.992)"
        string ToString() const override {
            string[] inner = {Name, 'rr: ' + RaceRank, 'tr: ' + TaRank, 'cp: ' + CpCount + ' (' + Time::Format(uint(LastCpTime)) + ")", tostring(SpawnStatus), 'bt: ' + Time::Format(BestTime), 'lrs: ' + Time::Format(LastRespawnRaceTime)};
            return "PlayerCpInfo(" + string::Join(inner, ", ") + ")";
        }
    }

    /* Each's players status in the race, with a focus on CP related info. */
    shared class PlayerCpInfo_V3 : PlayerCpInfo_V2 {
        // this player's CP times for their best lap this session, measured from the start of the lap.
        const array<uint>@ BestLapTimes;

        PlayerCpInfo_V3(MLHook::PendingEvent@ event, uint _spawnIndex) {
            super(event, _spawnIndex);
        }
        PlayerCpInfo_V3(PlayerCpInfo_V3@ _from, int cpOffset) {
            super(_from, cpOffset);
        }
    }

    /* Each's players status in the race, with a focus on CP related info. */
    shared class PlayerCpInfo_V4 : PlayerCpInfo_V3 {
        PlayerCpInfo_V4(MLHook::PendingEvent@ event, uint _spawnIndex) {
            super(event, _spawnIndex);
        }
        PlayerCpInfo_V4(PlayerCpInfo_V4@ _from, int cpOffset) {
            super(_from, cpOffset);
        }
        // The player's current lap.
        uint CurrentLap;
        // The player's WebServicesUserId
        string WebServicesUserId;
        // The player's Login (note: if you can, use WebServicesUserId instead)
        string Login;

        // The points the player earned this round. Reset on Playing UI sequence.
        int RoundPoints = 0;
        // The points total of this player. Updated with +RoundPoints on EndRound UI sequence (before RoundPoints is reset).
        int Points = 0;
        // The team the player is on. 1 = Blue, 2 = Red.
        int TeamNum = -1;
        // Whether the player is currently the MVP (for MM / Ranked)
        bool IsMVP = false;

        // Return's the players CSmPlayer object if it is available, otherwise null. The full list of players is searched each time.
        CSmPlayer@ FindCSmPlayer() { throw("overloaded elsewhere"); return null; }
    }

    //shared
    // class PlayerCpInfo_V5 : PlayerCpInfo_V4 {
    //     PlayerCpInfo_V5(MLHook::PendingEvent@ event, uint _spawnIndex) {
    //         super(event, _spawnIndex);
    //     }

    //     PlayerCpInfo_V5(PlayerCpInfo_V5@ _from, int cpOffset) {
    //         super(_from, cpOffset);
    //     }

    //     // Whether the player is spawned
    //     bool get_IsSpawned() const {
    //         return spawnStatus == SpawnStatus::Spawned;
    //     }
    // }

    // direction to move; down=-1, up=1
    shared enum Dir {
        Down = -1, Up = 1
    }

    // sort method for players
    shared enum RankType {
        Race, RaceRespawns, TimeAttack
    }

    shared class HookRaceStatsEventsBase : MLHook::HookMLEventsByType {
        // the prior map, prefer .Map
        string lastMap;
        // internal... but it's a map of player name => player object
        dictionary latestPlayerStats;
        // internal, deprecated
        array<PlayerCpInfo@> sortedPlayers_Race;
        // internal, deprecated
        array<PlayerCpInfo@> sortedPlayers_TimeAttack;
        /* The number of checkpoints each lap.
           Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.
        */
        uint CpCount;
        /* The number of laps for this map. */
        uint LapCount;
        /** This increments by 1 each frame a player spawns.
         * When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
         * This is useful for some sorting methods.
         * This value is set to 0 on plugin load and never reset.
        */
        uint SpawnCounter = 0;

        HookRaceStatsEventsBase(const string &in type) {
            super(type);
        }

        // *deprecated; use GetPlayer_V4* get a player's cp info
        PlayerCpInfo@ GetPlayer(const string &in name) {
            return cast<PlayerCpInfo>(latestPlayerStats[name]);
        }

        /* The number of waypoints a player needs to hit to finish the race.
           In single lap races, this is 1 more than `.CPCount`.
        */
        uint get_CPsToFinish() const final {
            return (CpCount + 1) * LapCount;
        }
    }

    /**
     * The main class used to access race data.
     * It exposes 3 sorted lists of players, and general information about the map/race.
     */
    shared class HookRaceStatsEventsBase_V2 : HookRaceStatsEventsBase {
        protected array<PlayerCpInfo_V2@> v2_sortedPlayers_Race;
        protected array<PlayerCpInfo_V2@> v2_sortedPlayers_TimeAttack;
        protected array<PlayerCpInfo_V2@> v2_sortedPlayers_Race_Respawns;

        HookRaceStatsEventsBase_V2(const string &in type) {
            super(type);
        }

        /* Get a player's info */
        const PlayerCpInfo_V2@ GetPlayer_V2(const string &in name) const {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V2>(latestPlayerStats[name]);
        }

        // internal
        PlayerCpInfo_V2@ _GetPlayer_V2(const string &in name) {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V2>(latestPlayerStats[name]);
        }

        /* An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest. */
        const array<PlayerCpInfo_V2@>@ get_SortedPlayers_Race() const {
            return v2_sortedPlayers_Race;
        }

        /* An array of `PlayerCpInfo_V2`s sorted by best time to worst time. */
        const array<PlayerCpInfo_V2@>@ get_SortedPlayers_TimeAttack() const {
            return v2_sortedPlayers_TimeAttack;
        }

        /* An array of `PlayerCpInfo_V2`s sorted by most checkpoints to fewest, accounting for player respawns. */
        const array<PlayerCpInfo_V2@>@ get_SortedPlayers_Race_Respawns() const {
            return v2_sortedPlayers_Race_Respawns;
        }

        // internal
        array<PlayerCpInfo_V2@>@ get__SortedPlayers_Race() {
            return v2_sortedPlayers_Race;
        }

        // internal
        array<PlayerCpInfo_V2@>@ get__SortedPlayers_TimeAttack() {
            return v2_sortedPlayers_TimeAttack;
        }

        // internal
        array<PlayerCpInfo_V2@>@ get__SortedPlayers_Race_Respawns() {
            return v2_sortedPlayers_Race_Respawns;
        }

        /* The number of checkpoints each lap.
           Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.
        */
        uint get_CPCount() const {
            return CpCount;
        }

        /* The map UID */
        const string get_Map() {
            return lastMap;
        }

	    /* When the player sets a new personal best, this is set to that time.
           Reset to -1 at the start of each map.
           Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`
        */
        int get_LastRecordTime() const {
            // return recHook.LastRecordTime;
            throw("implemented elsewhere");
            return 0;
        }
    }

    /**
     * The main class used to access race data.
     * It exposes 3 sorted lists of players, and general information about the map/race.
     */
    shared class HookRaceStatsEventsBase_V3 : HookRaceStatsEventsBase_V2 {
        HookRaceStatsEventsBase_V3(const string &in type) {
            super(type);
        }

        /* Get a player's info */
        const PlayerCpInfo_V3@ GetPlayer_V3(const string &in name) const {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V3>(latestPlayerStats[name]);
        }

        // internal
        PlayerCpInfo_V3@ _GetPlayer_V3(const string &in name) {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V3>(latestPlayerStats[name]);
        }
    }

    shared enum QualificationStage {
        Null = 0,
        ServerInitializing = 1,
        WaitingForStart = 2,
        Running = 3,
        MatchesGenerating = 4,
        ServerReady = 5,
        TooLateToJoinKO = 6,
        ServerEndingSoon = 7,
    }

    /**
     * The main class used to access race data.
     * It exposes 3 sorted lists of players, and general information about the map/race.
     */
    shared class HookRaceStatsEventsBase_V4 : HookRaceStatsEventsBase_V3 {
        // Qualification time known locally
        int COTDQ_LocalRaceTime;
        // Qualification time according to the API
        int COTDQ_APIRaceTime;
        // Qualification Rank, updated regularly (3-7s)
        int COTDQ_Rank;
        // Time you joined the server
        int COTDQ_QualificationsJoinTime;
        // Stage that qualification is in;
        QualificationStage COTDQ_QualificationsProgress;
        // true when you load into a server before it has gotten your record from the API
        bool COTDQ_IsSynchronizingRecord;
        // Incremented each time any COTD thing is updated
        int COTDQ_UpdateNonce;

        HookRaceStatsEventsBase_V4(const string &in type) {
            super(type);
        }

        /* Get a player's info */
        const PlayerCpInfo_V4@ GetPlayer_V4(const string &in name) const {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V4>(latestPlayerStats[name]);
        }

        // internal
        PlayerCpInfo_V4@ _GetPlayer_V4(const string &in name) {
            if (not latestPlayerStats.Exists(name)) return null;
            return cast<PlayerCpInfo_V4>(latestPlayerStats[name]);
        }
    }

    shared class HookRecordEventsBase : MLHook::HookMLEventsByType {
        protected int _lastRecordTime = -1;

        HookRecordEventsBase(const string &in type) {
            super(type);
        }

	    /** When the player sets a new personal best, this is set to that time.
        * Reset to -1 at the start of each map.
        * Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`
        */
        int get_LastRecordTime() const final {
            return _lastRecordTime;
        }
    }

    /* Provides race data.
       It is a proxy for the internal type `RaceFeed::HookRaceStatsEvents`. */
    shared class RaceDataProxy {
        private HookRaceStatsEventsBase@ hook;
        private HookRecordEventsBase@ recHook;
        RaceDataProxy(HookRaceStatsEventsBase@ h, HookRecordEventsBase@ rh) {
            if (h is null) throw('cannot have null thing');
            @hook = h;
            @recHook = rh;
        }
        /* Get a player by name (see `.SortedPlayers_Race/TimeAttack` for players) */
        const PlayerCpInfo@ GetPlayer(const string &in name) const {
            return hook.GetPlayer(name);
        }
        /* The map UID */
        const string get_Map() const {
            return hook.lastMap;
        }
        /* An array of `PlayerCpInfo`s sorted by most checkpoints to fewest. */
        const array<PlayerCpInfo@> get_SortedPlayers_Race() const {
            return hook.sortedPlayers_Race;
        }
        /* An array of `PlayerCpInfo`s sorted by best time to worst time. */
        const array<PlayerCpInfo@> get_SortedPlayers_TimeAttack() const {
            return hook.sortedPlayers_TimeAttack;
        }
        /* The number of checkpoints each lap.
           Linked checkpoints are counted as 1 checkpoint, and goal waypoints are not counted.
        */
        uint get_CPCount() const {
            return hook.CpCount;
        }
        /* The number of laps for this map. */
        uint get_LapCount() const {
            return hook.LapCount;
        }
        /* The number of waypoints a player needs to hit to finish the race.
           In single lap races, this is 1 more than `.CPCount`.
        */
        uint get_CPsToFinish() const {
            return hook.CPsToFinish;
        }
        /* This increments by 1 each frame a player spawns.
           When players spawn simultaneously, their PlayerCpInfo.spawnIndex values are the same.
           This is useful for some sorting methods.
           This value is set to 0 on plugin load and never reset.
        */
        uint get_SpawnCounter() const {
            return hook.SpawnCounter;
        }
	    /* When the player sets a new personal best, this is set to that time.
           Reset to -1 at the start of each map.
           Usage: `if (lastRecordTime != RaceData.LastRecordTime) OnNewRecord();`
        */
        int get_LastRecordTime() const {
            return recHook.LastRecordTime;
        }
    }

    /* Provides access to ghost info.
        This includes record ghosts loaded through the UI, and personal best ghosts.
        When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
    */
    shared class SharedGhostDataHook : MLHook::HookMLEventsByType {
        SharedGhostDataHook(const string &in type) { super(type); }
        // Number of ghosts that have been loaded on this map, including unloaded ghosts
        uint get_NbGhosts() const { return 0; };
        // *Deprecated, prefer .Ghosts_V2*; Array of GhostInfos
        const array<const MLFeed::GhostInfo@> get_Ghosts() const { return {}; };
    }

    /* Provides access to ghost info.
        This includes record ghosts loaded through the UI, and personal best ghosts.
        When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
        V2 adds .IsLocalPlayer and .IsPersonalBest properties to GhostInfo objects.
    */
    shared class SharedGhostDataHook_V2 : SharedGhostDataHook {
        // Currently loaded ghosts -- sorted fastest to slowest.
        array<MLFeed::GhostInfo_V2@> LoadedGhosts;
        // Known ghosts -- sorted fastest to slowest.
        array<MLFeed::GhostInfo_V2@> SortedGhosts;

        SharedGhostDataHook_V2(const string &in type) { super(type); }
        // Array of GhostInfo_V2s
        const array<const MLFeed::GhostInfo_V2@> get_Ghosts_V2() const { return {}; };
        // Number of currently loaded ghosts
        uint get_NbLoadedGhosts() const { return LoadedGhosts.Length; }
    }

    /** Information about a currently loaded ghost.
     * Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`
     */
    shared class GhostInfo {
        private string _IdName;
        private uint _IdUint;
        private string _Nickname;
        private int _Result_Score;
        private int _Result_Time;
        private uint[] _Checkpoints;

        // data: {IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with `,`)}
        GhostInfo(const MLHook::PendingEvent@ &in event) {
            if (event.data.Length < 5) {
                warn("GhostInfo attempted instatiation with event.data.Length < 5. Bailing.");
                return;
            }
            _IdName = event.data[0];
            _Nickname = event.data[1];
            _Result_Score = Text::ParseInt(event.data[2]);
            _Result_Time = Text::ParseInt(event.data[3]);
            string[] cpTimes = string(event.data[4]).Split(",");
            for (uint i = 0; i < cpTimes.Length; i++) {
                _Checkpoints.InsertLast(Text::ParseUInt(cpTimes[i]));
            }
            if (_IdName.Length > 0) {
                _IdUint = Text::ParseUInt(_IdName.SubStr(1));
            }
        }

        bool opEquals(const GhostInfo@ &in other) const {
            bool isEqNoCps = true
                && _IdName == other.IdName
                && _Nickname == other.Nickname
                && _Result_Score == other.Result_Score
                && _Result_Time == other.Result_Time
                && _Checkpoints.Length == other.Checkpoints.Length
                ;
            if (isEqNoCps) {
                for (uint i = 0; i < _Checkpoints.Length; i++) {
                    if (_Checkpoints[i] != other.Checkpoints[i])
                        return false;
                }
            }
            return isEqNoCps;
        }

        // Ghost.IdName
        const string get_IdName() const { return _IdName; }
        // Should be equiv to Ghost.Id.Value (experimental)
        uint get_IdUint() const { return _IdUint; }
        // Ghost.Nickname
        const string get_Nickname() const { return _Nickname; }
        // Ghost.Result.Score
        int get_Result_Score() const { return _Result_Score; }
        // Ghost.Result.Time
        int get_Result_Time() const { return _Result_Time; }
        // Ghost.Result.Checkpoints
        const uint[]@ get_Checkpoints() const { return _Checkpoints; }
    }

    /** Information about a currently loaded ghost.
     * Constructor expects a pending event with data: `{IdName, Nickname, Result_Score, Result_Time, cpTimes (as string joined with ',')}`
     */
    shared class GhostInfo_V2 : GhostInfo {
        // Whether this is the local player (sitting at this computer) -- includes PBs
        bool IsLocalPlayer;
        // Whether this is a PB ghost (named: 'Personal best')
        bool IsPersonalBest;
        // Whether this ghost is currently loaded in DataFileMgr
        bool IsLoaded = true;

        GhostInfo_V2(const MLHook::PendingEvent@ &in event) {
            super(event);
            IsPersonalBest = Nickname == "Personal best"; // fixed by HookGhostData
            IsLocalPlayer = IsPersonalBest || Nickname == LocalPlayersName;
        }
    }

    // returns the name of the local player, or an empty string if this is not yet known
    shared const string get_LocalPlayersName() {
        try {
            return cast<CTrackMania>(GetApp()).MenuManager.ManialinkScriptHandlerMenus.LocalUser.Name;
        } catch {}
        return "";
    }

    // The current server's GameTime, or 0 if not in a server
    shared uint get_GameTime() {
        if (GetApp().Network.PlaygroundClientScriptAPI is null) return 0;
        return uint(GetApp().Network.PlaygroundClientScriptAPI.GameTime);
    }
}
