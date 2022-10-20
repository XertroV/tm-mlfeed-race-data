namespace MLFeed {
    shared class KoPlayerState {
        string name;
        bool isAlive = true;
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

    shared class KoDataProxy {
        private HookKoStatsEventsBase@ hook;
        KoDataProxy(HookKoStatsEventsBase@ h) {
            @hook = h;
        }
        const KoPlayerState@ GetPlayerState(const string &in name) const {
            return hook.GetPlayerState(name);
        }
        const string get_Map() const {
            return hook.lastMap;
        }
        const string get_GameMode() const {
            return hook.lastGM;
        }
        const string[] get_Players() const {
            return hook.players;
        }
        int get_Division() const {
            return hook.division;
        }
        int get_MapRoundNb() const {
            return hook.mapRoundNb;
        }
        int get_MapRoundTotal() const {
            return hook.mapRoundTotal;
        }
        int get_RoundNb() const {
            return hook.roundNb;
        }
        int get_RoundTotal() const {
            return hook.roundTotal;
        }
        int get_PlayersNb() const {
            return hook.playersNb;
        }
        int get_KOsMilestone() const {
            return hook.kosMilestone;
        }
        int get_KOsNumber() const {
            return hook.kosNumber;
        }
    }

    shared enum SpawnStatus {
        NotSpawned = 0,
        Spawning = 1,
        Spawned = 2
    }

    shared class PlayerCpInfo {
        string name;
        int cpCount;
        int lastCpTime;
        int[] cpTimes;
        int bestTime;
        SpawnStatus spawnStatus;
        uint spawnIndex = 0;
        uint taRank = 0;  // set by hook; not sure if we can get it from ML
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

        bool get_IsSpawned() {
            return spawnStatus == SpawnStatus::Spawned;
        }
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

    shared class RaceDataProxy {
        private HookRaceStatsEventsBase@ hook;
        private HookRecordEventsBase@ recHook;
        RaceDataProxy(HookRaceStatsEventsBase@ h, HookRecordEventsBase@ rh) {
            @hook = h;
            @recHook = rh;
        }
        const PlayerCpInfo@ GetPlayer(const string &in name) const {
            return hook.GetPlayer(name);
        }
        const string get_Map() const {
            return hook.lastMap;
        }
        const array<PlayerCpInfo@> get_SortedPlayers_Race() const {
            return hook.sortedPlayers_Race;
        }
        const array<PlayerCpInfo@> get_SortedPlayers_TimeAttack() const {
            return hook.sortedPlayers_TimeAttack;
        }
        uint get_CPCount() const {
            return hook.CpCount;
        }
        uint get_LapCount() const {
            return hook.LapCount;
        }
        uint get_CPsToFinish() const {
            return hook.CPsToFinish;
        }
        uint get_SpawnCounter() const {
            return hook.SpawnCounter;
        }
        int get_LastRecordTime() const {
            return recHook.LastRecordTime;
        }
    }
}
