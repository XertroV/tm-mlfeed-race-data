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

    shared class HookKoStatsEventsBase : MLHook::HookMLEventsByType {
        HookKoStatsEventsBase(const string &in type) {
            super(type);
        }

        string lastGM;
        string lastMap;
        string[] players;

        int division = -1; // ServerNumber
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
        // The times of each of their CPs since respawning
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

    shared class HookRaceStatsEventsBase : MLHook::HookMLEventsByType {
        string lastMap;
        dictionary latestPlayerStats;
        array<PlayerCpInfo@> sortedPlayers_Race;
        array<PlayerCpInfo@> sortedPlayers_TimeAttack;
        uint CpCount;
        uint LapCount;
        uint SpawnCounter = 0;

        HookRaceStatsEventsBase(const string &in type) {
            super(type);
        }

        PlayerCpInfo@ GetPlayer(const string &in name) {
            return cast<PlayerCpInfo>(latestPlayerStats[name]);
        }

        uint get_CPsToFinish() const final {
            return (CpCount + 1) * LapCount;
        }
    }

    shared class HookRecordEventsBase : MLHook::HookMLEventsByType {
        protected int _lastRecordTime = -1;

        HookRecordEventsBase(const string &in type) {
            super(type);
        }

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
        When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded.
    */
    shared class SharedGhostDataHook : MLHook::HookMLEventsByType {
        SharedGhostDataHook(const string &in type) { super(type); }
        // Number of currently loaded ghosts
        uint get_NbGhosts() const { return 0; };
        // Array of GhostInfos
        const array<const MLFeed::GhostInfo@> get_Ghosts() const { return {}; };
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
}
