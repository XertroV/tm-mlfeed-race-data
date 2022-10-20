void Main() {
    MLHook::RequireVersionApi('0.3.2');

    // initial objects, get them non-null ASAP
    @theHook = RaceFeed::HookRaceStatsEvents();
    @koFeedHook = KoFeed::HookKoStatsEvents();
    @recordHook = HookRecordFeed();

    startnew(InitCoro);
}

void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading hooks and removing injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}

void InitCoro() {
    string KOsEvent = KoFeed::KOsEvent;
    // Race Stats
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerCP");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerLeft");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerRaceTimes");
    // ko feed hook
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_PlayerStatus");
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_MatchKeyPair");
    // records
    // todo?: make optional component that must be requested to load
    MLHook::RegisterMLHook(recordHook, recordHook.type, true);

    // ml load
    yield(); // time for hooks to be instantiated etc
    MLHook::InjectManialinkToPlayground("MLFeedRace", RACESTATSFEED_SCRIPT_TXT, true);
    MLHook::InjectManialinkToPlayground("MLFeedKOs", MLFEEDKOS_SCRIPT_TXT, true);
    yield(); // wait 2 frames for ML to load
    yield();
    // start coros
    startnew(CoroutineFunc(theHook.MainCoro));
    startnew(CoroutineFunc(koFeedHook.MainCoro));

#if DEV
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

namespace RaceFeed {
    enum Cmp {Lt = -1, Eq = 0, Gt = 1}

    funcdef Cmp CmpPlayers(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2);
    funcdef bool LessPlayers(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2);


    Cmp cmpRace(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2) {
        // if we're in race mode, then we want to count the player as spawned if their spawnIndex == SpawnCounter
        MLFeed::SpawnStatus p1SS = p1.spawnStatus;
        MLFeed::SpawnStatus p2SS = p2.spawnStatus;
        if (theHook !is null) {
            if (p1.spawnStatus == MLFeed::SpawnStatus::NotSpawned && p1.spawnIndex == theHook.SpawnCounter)
                p1SS = MLFeed::SpawnStatus::Spawned;
            if (p2.spawnStatus == MLFeed::SpawnStatus::NotSpawned && p2.spawnIndex == theHook.SpawnCounter)
                p2SS = MLFeed::SpawnStatus::Spawned;
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

    bool lessRace(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2) {
        return cmpRace(p1, p2) == Cmp::Lt;
    }

    Cmp cmpTimeAttack(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2) {
        if (p1.bestTime == p2.bestTime) return cmpRace(p1, p2);
        if (p1.bestTime < 0) return Cmp::Gt;
        if (p2.bestTime < 0) return Cmp::Lt;
        if (p1.bestTime < p2.bestTime) return Cmp::Lt;
        return Cmp::Gt;
    }

    bool lessTimeAttack(const MLFeed::PlayerCpInfo@ &in p1, const MLFeed::PlayerCpInfo@ &in p2) {
        return cmpTimeAttack(p1, p2) == Cmp::Lt;
    }

    Cmp cmpInt(int a, int b) {
        if (a < b) return Cmp::Lt;
        if (a == b) return Cmp::Eq;
        return Cmp::Gt;
    }

    // todo: add past list that tracks last known time of player?

    class HookRaceStatsEvents : MLFeed::HookRaceStatsEventsBase {
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
            MLFeed::PlayerCpInfo@ player;
            bool hadPlayer = latestPlayerStats.Get(name, @player);
            if (hadPlayer) {
                player.UpdateFrom(event, spawnIx);
            } else {
                @player = MLFeed::PlayerCpInfo(event, spawnIx);
                @latestPlayerStats[name] = player;
                sortedPlayers_Race.InsertLast(player);
                sortedPlayers_TimeAttack.InsertLast(player);
                player.raceRank = sortedPlayers_Race.Length;
                player.taRank = sortedPlayers_TimeAttack.Length;
            }

            if (player.spawnStatus == MLFeed::SpawnStatus::Spawned && player.cpCount == 0) {
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

        void UpdatePlayerPosition(MLFeed::PlayerCpInfo@ player) {
            // when a player is updated, they usually only go up or down by a few places at most.
            UpdatePlayerInSortedPlayersWithMethod(player, sortedPlayers_TimeAttack, LessPlayers(lessTimeAttack), false);
            UpdatePlayerInSortedPlayersWithMethod(player, sortedPlayers_Race, LessPlayers(lessRace), true);
        }

        // todo, refactor to use SortMethod
        void UpdatePlayerInSortedPlayersWithMethod(MLFeed::PlayerCpInfo@ player, array<MLFeed::PlayerCpInfo@>@ &in sorted, LessPlayers@ lessFunc, bool isRace) {
            uint ix = sorted.FindByRef(player);
            MLFeed::PlayerCpInfo@ tmp;
            if (ix >= sorted.Length) return;
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
            // todo, need to go the other way, too?
            // necessary when race sorted but not everyone gets reset at the same time
            while (ix < sorted.Length - 1 && lessFunc(sorted[ix + 1], player)) {
                // swap these players
                @tmp = sorted[ix + 1];
                @sorted[ix + 1] = player;
                @sorted[ix] = tmp;
                ix++;
                if (isRace) {
                    player.raceRank++;
                    tmp.raceRank--;
                } else {
                    player.taRank++;
                    tmp.taRank--;
                }
            }

            // fix rankings if players dropped out -- todo: mb do this in updatePlayerLeft
            if (1 != (isRace ? sorted[0].raceRank : sorted[0].taRank)) {
                if (isRace) sorted[0].raceRank = 1;
                else sorted[0].taRank = 1;
            }
            for (int i = 0; i < sorted.Length - 1; i++) {
                auto preRank = isRace ? sorted[i].raceRank : sorted[i].taRank;
                auto postRank = isRace ? sorted[i+1].raceRank : sorted[i+1].taRank;
                if (preRank + 1 != postRank) {
                    if (isRace) sorted[i+1].raceRank = preRank + 1;
                    else sorted[i+1].taRank = preRank + 1;
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

        void SetCheckpointCount() {
            auto cp = cast<CSmArenaClient>(GetApp().CurrentPlayground);
            while (cp is null) {
                yield();
                @cp = cast<CSmArenaClient>(GetApp().CurrentPlayground);
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

        void OnMapChange() {
            latestPlayerStats.DeleteAll();
            sortedPlayers_TimeAttack.RemoveRange(0, sortedPlayers_TimeAttack.Length);
            sortedPlayers_Race.RemoveRange(0, sortedPlayers_Race.Length);
            this.CpCount = 0;
            if (CurrentMap != "") {
                startnew(CoroutineFunc(SetCheckpointCount));
            }
        }

        private string _localUserName;
        string get_LocalUserName() {
            if (_localUserName.Length == 0) {
                auto pcsa = GetApp().Network.PlaygroundClientScriptAPI;
                if (pcsa !is null && pcsa.LocalUser !is null) {
                    _localUserName = pcsa.LocalUser.Name;
                }
            }
            return _localUserName;
        }
    }
}

string get_CurrentMap() {
    auto map = GetApp().RootMap;
    if (map is null) return "";
    // return map.EdChallengeId;
    return map.MapInfo.MapUid;
}
