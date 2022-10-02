MLFeed::HookRaceStatsEvents@ theHook = null;
MLFeed::HookKoStatsEvents@ koFeedHook = null;

/*

todo show green when players fin


 */
void Main() {
    MLHook::RequireVersionApi('0.2.1');

    // initial objects, get them non-null ASAP
    @theHook = MLFeed::HookRaceStatsEvents();
    @koFeedHook = MLFeed::HookKoStatsEvents();

    startnew(InitCoro);
}

void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading hooks and removing injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}

void InitCoro() {
    string KOsEvent = MLFeed::KOsEvent;
    // Race Stats
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerCP");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerLeft");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerRaceTimes");
    // ko feed hook
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_PlayerStatus");
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_MatchKeyPair");

    // ml load
    yield();
    IO::FileSource refreshCode("RaceStatsFeed.Script.txt");
    MLHook::InjectManialinkToPlayground("MLFeedRace", refreshCode.ReadToEnd(), true);
    IO::FileSource cotdML("MLFeedKOs.Script.txt");
    MLHook::InjectManialinkToPlayground("MLFeedKOs", cotdML.ReadToEnd(), true);
    yield();
    yield();
    // start coros
    startnew(CoroutineFunc(theHook.MainCoro));
    startnew(CoroutineFunc(koFeedHook.MainCoro));

#if DEV
    // cotd hook setup
    auto devHook = MLHook::DebugLogAllHook("MLHook_Event_" + KOsEvent);
    MLHook::RegisterMLHook(devHook, KOsEvent + "_PlayerStatus");
    MLHook::RegisterMLHook(devHook, KOsEvent + "_MatchKeyPair");
    // MLHook::RegisterMLHook(devHook, "RaceStats"); // bc its the debug hook
    // MLHook::RegisterMLHook(devHook, "RaceStats_ActivePlayers"); // bc its the debug hook
#endif
}

#if SIG_DEVELOPER
void Render() {
    KoFeedUI::Render();
    RaceFeedUI::Render();
}
#endif

void RenderInterface() {
}

#if SIG_DEVELOPER
void RenderMenu() {
    KoFeedUI::RenderMenu();
    RaceFeedUI::RenderMenu();
}
#endif

enum SortMethod {
    Race, TimeAttack
}

/* with race, the winning players unspawn. how to differentiate?
maybe track *when* they unspawned, and group those.
so active racers get grouped with most recent unspawn.
then, when the respawn happens, racers all respawn at the same time,
so we can track the number of respawns
*/

SortMethod[] AllSortMethods = {Race, TimeAttack};

[Setting hidden]
SortMethod g_sortMethod = SortMethod::TimeAttack;
[Setting hidden]
bool Setting_ShowBestTimeCol = true;
[Setting hidden]
bool Setting_ShowPastCPs = false;


namespace MLFeed {
    funcdef Cmp CmpPlayers(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2);
    funcdef bool LessPlayers(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2);

    Cmp cmpPlayerCpInfo(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2) {
        switch (g_sortMethod) {
            case SortMethod::Race: return cmpRace(p1, p2);
            case SortMethod::TimeAttack: return cmpTimeAttack(p1, p2);
            // default: break;
        }
        warn("Unknown sort method: " + tostring(g_sortMethod));
        return Cmp::Eq;
    }


    Cmp cmpRace(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2) {
        // if we're in race mode, then we want to count the player as spawned if their spawnIndex == SpawnCounter
        SpawnStatus p1SS = p1.spawnStatus;
        SpawnStatus p2SS = p2.spawnStatus;
        if (theHook !is null) {
            if (p1.spawnStatus == SpawnStatus::NotSpawned && p1.spawnIndex == theHook.SpawnCounter)
                p1SS = SpawnStatus::Spawned;
            if (p2.spawnStatus == SpawnStatus::NotSpawned && p2.spawnIndex == theHook.SpawnCounter)
                p2SS = SpawnStatus::Spawned;
        }
        // spawned status dominates
        if (p1SS != p2SS) {
            // not spawned is smallest, so we want the opposite of cmpInt, so flip the args
            return cmpInt(int(p2SS), int(p1SS));
        }
        // if we have the same CPs, lowest time is better
        if (p1.cpCount == p2.cpCount)
            return cmpInt(p1.lastCpTime, p2.lastCpTime);
        // Lt => better ranking, so more CPs is better
        if (p1.cpCount > p2.cpCount) return Cmp::Lt;
        return Cmp::Gt;
    }

    bool lessRace(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2) {
        return cmpRace(p1, p2) == Cmp::Lt;
    }

    Cmp cmpTimeAttack(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2) {
        if (p1.bestTime == p2.bestTime) return cmpRace(p1, p2);
        if (p1.bestTime < 0) return Cmp::Gt;
        if (p2.bestTime < 0) return Cmp::Lt;
        if (p1.bestTime < p2.bestTime) return Cmp::Lt;
        return Cmp::Gt;
    }

    bool lessTimeAttack(const PlayerCpInfo@ &in p1, const PlayerCpInfo@ &in p2) {
        return cmpTimeAttack(p1, p2) == Cmp::Lt;
    }

    Cmp cmpInt(int a, int b) {
        if (a < b) return Cmp::Lt;
        if (a == b) return Cmp::Eq;
        return Cmp::Gt;
    }

    shared enum Cmp {Lt = -1, Eq = 0, Gt = 1}

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

        // int opCmp(PlayerCpInfo@ other) {
        //     return int(cmpPlayerCpInfo(this, other));
        // }
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
    }

    class HookRaceStatsEvents : HookRaceStatsEventsBase {
        // props defined in HookRaceStatsEventsBase
        MLHook::PendingEvent@[] incoming_msgs;

        HookRaceStatsEvents() {
            super("RaceStats");
        }

        void MainCoro() {
            sleep(50);
            MLHook::Queue_MessageManialinkPlayground("RaceStats", {"SendAllPlayerStates"});
            while (true) {
                yield();
                while (incoming_msgs.Length > 0) {
                    ProcessMsg(incoming_msgs[incoming_msgs.Length - 1]);
                    incoming_msgs.RemoveLast();
                }
                if (lastMap != CurrentMap) {
                    lastMap = CurrentMap;
                    OnMapChange();
                }
            }
        }

        void ProcessMsg(MLHook::PendingEvent@ event) {
            if (event.type.EndsWith("PlayerLeft")) {
                // update active player list
                UpdatePlayerLeft(event);
            } else if (event.type.EndsWith("PlayerRaceTimes")) {
                // UpdatePlayerRaceTimes(event.data[0], event.data[1]);
            } else if (event.type.EndsWith("PlayerCP")) {
                UpdatePlayer(event);
            }
        }

        // void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override {
        void OnEvent(MLHook::PendingEvent@ event) override {
            incoming_msgs.InsertLast(event);
        }

        /* main functionality logic */

        void UpdatePlayer(MLHook::PendingEvent@ event) {
            uint spawnIx = SpawnCounter;
            string name = event.data[0];
            PlayerCpInfo@ player;
            bool hadPlayer = latestPlayerStats.Get(name, @player);
            if (hadPlayer) {
                player.UpdateFrom(event, spawnIx);
            } else {
                @player = PlayerCpInfo(event, spawnIx);
                @latestPlayerStats[name] = player;
                sortedPlayers_Race.InsertLast(player);
                sortedPlayers_TimeAttack.InsertLast(player);
                player.raceRank = sortedPlayers_Race.Length;
                player.taRank = sortedPlayers_TimeAttack.Length;
            }

            if (player.spawnStatus == SpawnStatus::Spawned && player.cpCount == 0) {
                SpawnCounter += 1;
            }
            // race events don't update the local players best time until they've respawned for some reason (other ppl are immediate)
            if (player.cpCount == int(this.CPsToFinish) && player.name == LocalUserName && player.IsSpawned) {
                int bt = int(player.bestTime);
                if (bt <= 0) {
                    bt = 1 << 30;
                }
                player.bestTime = Math::Min(bt, player.lastCpTime);
            }
            UpdatePlayerPosition(player);
        }

        void UpdatePlayerPosition(PlayerCpInfo@ player) {
            // when a player is updated, they usually only go up or down by a few places at most.
            UpdatePlayerInSortedPlayersWithMethod(player, sortedPlayers_TimeAttack, LessPlayers(lessTimeAttack), false);
            UpdatePlayerInSortedPlayersWithMethod(player, sortedPlayers_Race, LessPlayers(lessRace), true);
        }

        // todo, refactor to use SortMethod
        void UpdatePlayerInSortedPlayersWithMethod(PlayerCpInfo@ player, array<PlayerCpInfo@>@ &in sorted, LessPlayers@ lessFunc, bool isRace) {
            uint ix = sorted.FindByRef(player);
            PlayerCpInfo@ tmp;
            if (ix < 0) return;
            // improving in rank
            while (ix > 0 && lessFunc(player, sorted[ix - 1])) {
                // swap these players
                @tmp = sorted[ix - 1];
                @sorted[ix - 1] = player;
                @sorted[ix] = tmp;
                ix--;
                if (isRace) {
                    player.raceRank--;
                    tmp.raceRank++;
                } else {
                    player.taRank--;
                    tmp.taRank++;
                }
            }
        }

        void UpdatePlayerLeft(MLHook::PendingEvent@ event) {
            string name = event.data[0];
            auto player = GetPlayer(name);
            if (player !is null) {
                uint ix = sortedPlayers_Race.FindByRef(player);
                if (ix >= 0) sortedPlayers_Race.RemoveAt(ix);
                ix = sortedPlayers_TimeAttack.FindByRef(player);
                if (ix >= 0) sortedPlayers_TimeAttack.RemoveAt(ix);
                latestPlayerStats.Delete(name);
            }
        }

        void OnMapChange() {
            latestPlayerStats.DeleteAll();
            sortedPlayers_TimeAttack.RemoveRange(0, sortedPlayers_TimeAttack.Length);
            sortedPlayers_Race.RemoveRange(0, sortedPlayers_Race.Length);
            this.CpCount = 0;
            if (CurrentMap != "") {
                startnew(CoroutineFunc(SetCheckpointCount));
            }
        }

        string get_CurrentMap() const {
            auto map = GetApp().RootMap;
            if (map is null) return "";
            // return map.EdChallengeId;
            return map.MapInfo.MapUid;
        }

        void SetCheckpointCount() {
            while (cp is null) {
                yield();
            }
            auto landmarks = cp.Arena.MapLandmarks;
            uint cpCount = 0;
            auto lcps = dictionary();
            for (uint i = 0; i < landmarks.Length; i++) {
                auto landmark = cast<CSmScriptMapLandmark>(landmarks[i]);
                if (landmark is null) continue;
                auto waypoint = landmark.Waypoint;
                if (waypoint is null || waypoint.IsMultiLap || waypoint.IsFinish) continue;
                if (landmark.Tag == "Checkpoint") {
                    cpCount++;
                    continue;
                } else if (landmark.Tag == "LinkedCheckpoint") {
                    lcps.Set('' + landmark.Order, true);
                    continue;
                } else {
                    cpCount++;
                    warn('A cp was not as it appeared! had tag: ' + landmark.Tag);
                    continue;
                }
            }
            this.CpCount = cpCount + lcps.GetSize();
            this.LapCount = cp.Map.MapInfo.TMObjective_NbLaps;
        }

        uint get_CPsToFinish() {
            return (CpCount + 1) * LapCount;
        }
    }
}
