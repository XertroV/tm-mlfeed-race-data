void Main() {
    // initial objects, get them non-null ASAP
    @theHook = RaceFeed::HookRaceStatsEvents();
    @koFeedHook = KoFeed::HookKoStatsEvents();
    @recordHook = HookRecordFeed();
    @ghostHook = HookGhostData();
    @teamsFeed = TeamsFeed::HookTeamsMMEvents();

#if DEV
    // TestTeamsFeedScoring();
#endif

    startnew(InitCoro);

#if SIG_DEVELOPER
    S_ShowDebugMenu = true;
#endif
}

void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading hooks and removing injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
}

void InitCoro() {
    RaceFeed::Setup();

    string KOsEvent = KoFeed::KOsEvent;
    // Race Stats
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerCP");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerLeft");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerRaceTimes");
    MLHook::RegisterMLHook(theHook, "RaceStats_PlayerInfo");
    MLHook::RegisterMLHook(theHook, "RaceStats_MatchKeyPair");
    MLHook::RegisterMLHook(theHook, "RaceStats_COTDQualiInfo");
    MLHook::RegisterMLHook(theHook, "RaceStats_LapsNb");
    // ko feed hook
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_PlayerStatus");
    MLHook::RegisterMLHook(koFeedHook, KOsEvent + "_MatchKeyPair");
    // teams feed
    MLHook::RegisterMLHook(teamsFeed, TeamsFeed::Page_UID + "_MatchKeyPair");
    // records
    // todo?: make optional component that must be requested to load
    MLHook::RegisterMLHook(recordHook, recordHook.type, true);
    // GhostData
    MLHook::RegisterMLHook(ghostHook);
    MLHook::RegisterMLHook(ghostHook, "GhostData_Removed");

    // ml load
    yield(); // time for hooks to be instantiated etc
    string raceStatsScript = ProcessRaceStats2023_Oct(RACESTATSFEED_SCRIPT_TXT);
    MLHook::InjectManialinkToPlayground("MLFeedRace", raceStatsScript, true);
    MLHook::InjectManialinkToPlayground("MLFeedKOs", MLFEEDKOS_SCRIPT_TXT, true);
    MLHook::InjectManialinkToPlayground("MLFeedGhostData", GHOSTDATA_SCRIPT_TXT, true);
    MLHook::InjectManialinkToPlayground("MLFeedTeams", TEAMSFEED_SCRIPT_TXT, true);
    yield(); // wait 2 frames for ML to load
    yield();
    // start coros
    startnew(CoroutineFunc(theHook.MainCoro));
    startnew(CoroutineFunc(koFeedHook.MainCoro));
    startnew(CoroutineFunc(teamsFeed.MainCoro));

#if DEV
    auto devHook = MLHook::DebugLogAllHook("GhostData");
    MLHook::RegisterMLHook(devHook);
    // MLHook::RegisterMLHook(devHook, KOsEvent + "_MatchKeyPair");
    // MLHook::RegisterMLHook(devHook, "RaceStats"); // bc its the debug hook
    // MLHook::RegisterMLHook(devHook, "RaceStats_ActivePlayers"); // bc its the debug hook
#endif
}

[Setting category="Demo UIs" name="Show Demos Menu under Plugins"]
bool S_ShowDebugMenu = false;

void RenderInterface() {
    if (!S_ShowDebugMenu) return;
    KoFeedUI::Render();
    RaceFeedUI::Render();
    GhostDataUI::Render();
    TeamsFeed::RenderDemoUI();
}

void RenderMenu() {
    if (!S_ShowDebugMenu) return;
    if (UI::BeginMenu(Icons::Rss + " MLFeed::DemoUIs")) {
        KoFeedUI::RenderMenu();
        RaceFeedUI::RenderMenu();
        GhostDataUI::RenderMenu();
        TeamsFeed::RenderMenu();
        UI::EndMenu();
    }
}



/* with race, the winning players unspawn. how to differentiate?
maybe track *when* they unspawned, and group those.
so active racers get grouped with most recent unspawn.
then, when the respawn happens, racers all respawn at the same time,
so we can track the number of respawns
*/

namespace RaceFeed {
    enum Cmp {Lt = -1, Eq = 0, Gt = 1}

    funcdef Cmp CmpPlayers(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2);
    funcdef bool LessPlayers(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2);

    Cmp cmpRace(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
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

    bool lessRace(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
        return cmpRace(p1, p2) == Cmp::Lt;
    }

    Cmp cmpRaceRespawn(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
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
        if (p1.CpCount == p2.CpCount)
            return cmpInt(p1.LastCpOrRespawnTime, p2.LastCpOrRespawnTime);
        // Lt => better ranking, so more CPs is better
        if (p1.CpCount > p2.CpCount) return Cmp::Lt;
        return Cmp::Gt;
    }

    bool lessRaceRespawn(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
        return cmpRaceRespawn(p1, p2) == Cmp::Lt;
    }

    Cmp cmpTimeAttack(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
        if (p1.bestTime == p2.bestTime) return cmpRace(p1, p2);
        if (p1.bestTime < 0) return Cmp::Gt;
        if (p2.bestTime < 0) return Cmp::Lt;
        if (p1.bestTime < p2.bestTime) return Cmp::Lt;
        return Cmp::Gt;
    }

    bool lessTimeAttack(const MLFeed::PlayerCpInfo_V2@ p1, const MLFeed::PlayerCpInfo_V2@ p2) {
        return cmpTimeAttack(p1, p2) == Cmp::Lt;
    }

    Cmp cmpInt(int a, int b) {
        if (a < b) return Cmp::Lt;
        if (a == b) return Cmp::Eq;
        return Cmp::Gt;
    }

    class _PlayerCpInfo : MLFeed::PlayerCpInfo_V4 {
        _PlayerCpInfo(MLHook::PendingEvent@ event, uint _spawnIndex) {
            super(event, _spawnIndex);
            SetPlayerLoginWsid();
        }
        _PlayerCpInfo(_PlayerCpInfo@ _from, int cpOffset) {
            super(_from, cpOffset);
            SetPlayerLoginWsid();
        }

        _PlayerCpInfo(CSmPlayer@ player) {
            super(player);
            @Player = player;
            name = player.User.Name;
            Login = player.User.Login;
            WebServicesUserId = player.User.WebServicesUserId;
            playerScoreMwId = player.Score.Id.Value;
            @BestLapTimes = {};
            @BestRaceTimes = {};
            UpdateFromPlayer(player);
            theHook.AfterCreatedNewPlayer(this);
        }

        // Used to keep the reference to CSmPlayer safe to use or null
        void ResetUnsafeRefs() {
            @Player = null;
            FieldsUpdated = MLFeed::PlayerUpdateFlags::None;
        }



        void UpdateFromPlayer(CSmPlayer@ player) {
            if (player is null || player.ScriptAPI is null || player.Score is null) return;
            // trace('UpdateFromPlayer: ' + player.User.Name);
            auto api = cast<CSmScriptPlayer>(player.ScriptAPI);
            auto score = player.Score;
            @Player = player;

            bool raceReset, didRespawn, cpsChanged;

            cpsChanged = cpCount != api.RaceWaypointTimes.Length;
            if (cpsChanged) {
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::Checkpoint);
                cpCount = api.RaceWaypointTimes.Length;
                lastCpTime = cpCount == 0 ? 0 : api.RaceWaypointTimes[cpCount - 1];
                cpTimes.Resize(cpCount + 1);
                if (cpCount > 0) {
                    cpTimes[cpCount] = lastCpTime;
                }
            }
            if (NbRespawnsRequested != score.NbRespawnsRequested) {
                didRespawn = NbRespawnsRequested < score.NbRespawnsRequested;
                NbRespawnsRequested = score.NbRespawnsRequested;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::Respawn);
            }
            if (spawnIndex != player.SpawnIndex) {
                spawnIndex = player.SpawnIndex;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::SpawnIndex);
            }
            if (spawnStatus != MLFeed::SpawnStatus(api.SpawnStatus)) {
                spawnStatus = MLFeed::SpawnStatus(api.SpawnStatus);
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::SpawnStatus);
            }

            //trace('best race times; score is null: ' + (score is null));
            if (score.BestRaceTimes.Length > 0 && bestTime != score.BestRaceTimes[score.BestRaceTimes.Length - 1]) {
                bestTime = score.BestRaceTimes[score.BestRaceTimes.Length - 1];
                BestRaceTimes.Resize(score.BestRaceTimes.Length);
                for (uint i = 0; i < score.BestRaceTimes.Length; i++) {
                    BestRaceTimes[i] = score.BestRaceTimes[i];
                }
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::BestTime);
            }
            //trace('best lap times');
            if (score.BestLapTimes.Length > 0 && (BestLapTimes.Length == 0 || BestLapTimes[BestLapTimes.Length - 1] != score.BestLapTimes[score.BestLapTimes.Length - 1])) {
                auto nbCps = score.BestLapTimes.Length;
                BestLapTimes.Resize(nbCps);
                for (uint i = 0; i < nbCps; i++) {
                    BestLapTimes[i] = score.BestLapTimes[i];
                }
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::BestLapTimes);
            }
            //trace('current lap');
            if (CurrentLap != api.CurrentLapNumber) {
                CurrentLap = api.CurrentLapNumber;
                LapStartTime = api.LapStartTime;
                // api.CurrentLapWaypointTimes
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::CurrentLap);
            }
            //trace('start time');
            if (StartTime != api.StartTime) {
                raceReset = StartTime < api.StartTime;
                StartTime = api.StartTime;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::StartTime);
            }

            //trace('if raceReset: ' + raceReset);
            if (raceReset) {
                LastRespawnCheckpoint = 0;
                LastRespawnRaceTime = 0;
                TimeLostToRespawns = 0;
                ZeroIntArray(timeLostToRespawnsByCp);
                ZeroIntArray(nbRespawnsByCp);
                ZeroIntArray(respawnTimes);
                timeLostToRespawnsByCp.Resize(cpTimes.Length);
                nbRespawnsByCp.Resize(cpTimes.Length);
                respawnTimes.Resize(0);
            } else {
                timeLostToRespawnsByCp.Resize(cpCount + 1);
                nbRespawnsByCp.Resize(cpCount + 1);
                if (cpsChanged) {
                    timeLostToRespawnsByCp[cpCount] = 0;
                    nbRespawnsByCp[cpCount] = 0;
                    if (cpCount > 0) {
                        // update latency estimate
                        float lag = float(CurrentRaceTimeRaw - LastCpTime); // should be 0 if instant, or like 1 frame
                        auto n = Math::Min(9., lagDataPoints);
                        latencyEstimate = (latencyEstimate * n + lag) / (n + 1.); // simple exp/moving average type thing
                        lagDataPoints += 1;
                    }
                }
                if (didRespawn) {
                    // if we respawn at the start of the race (and it isn't a restart) then the car moves instantly
                    int respawnOverhead = cpCount == 0 ? 0 : 1000;
                    // lag is accounted for in CurrentRaceTime
                    int newTimeLost = respawnOverhead + Math::Max(0, CurrentRaceTime - LastCpTime);
                    LastRespawnRaceTime = respawnOverhead + CurrentRaceTime;
                    LastRespawnCheckpoint = cpCount;
                    TimeLostToRespawns -= timeLostToRespawnsByCp[cpCount];
                    timeLostToRespawnsByCp[cpCount] = newTimeLost;
                    TimeLostToRespawns += newTimeLost;
                    nbRespawnsByCp[cpCount] += 1;
                    respawnTimes.InsertLast(CurrentRaceTime);
                }
            }

            // still needed?
            // race events don't update the local players best time until they've respawned for some reason (other ppl are immediate)
            // if (player.cpCount == int(this.CPsToFinish) && player.name == LocalUserName && player.IsSpawned) {
            //     int bt = int(player.bestTime);
            //     if (bt <= 0) {
            //         bt = 1 << 30;
            //     }
            //     player.bestTime = Math::Min(bt, player.lastCpTime);
            // }

            //trace('fields updated check');
            if (FieldsUpdated > 0) {
                UpdateNonce++;
                theHook.UpdatePlayerPosition(this);
            }
        }

        void ModifyRank(MLFeed::Dir dir, MLFeed::RankType rt) override {
            MLFeed::PlayerCpInfo_V4::ModifyRank(dir, rt);
            FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::AnyRaceRank);
        }

        void UpdateFromScore(CSmPlayer@ player) {
            auto score = player.Score;
            if (TeamNum != score.TeamNum) {
                TeamNum = score.TeamNum;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::TeamNum);
            }
            if (RoundPoints != score.RoundPoints) {
                RoundPoints = score.RoundPoints;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::RoundPoints);
            }
            if (Points != score.Points) {
                Points = score.Points;
                FieldsUpdated = MLFeed::PlayerUpdateFlags(FieldsUpdated | MLFeed::PlayerUpdateFlags::Points);
            }
        }


        CSmPlayer@ FindCSmPlayer() override {
            auto cp = GetApp().CurrentPlayground;
            if (cp is null) return null;
            for (uint i = 0; i < cp.Players.Length; i++) {
                auto player = cast<CSmPlayer>(cp.Players[i]);
                if (player !is null && player.User.Name == Name) {
                    return player;
                }
            }
            return null;
        }

        void SetPlayerLoginWsid() {
            auto net = GetApp().Network;
            for (uint i = 0; i < net.PlayerInfos.Length; i++) {
                auto item = cast<CGamePlayerInfo>(net.PlayerInfos[i]);
                if (string(item.Name) == this.Name) {
                    Login = item.Login;
                    WebServicesUserId = item.WebServicesUserId;
                }
            }
        }

        void UpdateScoreFrom(const string[] &in parts) {
            TeamNum = Text::ParseInt(parts[1]);
            RoundPoints = Text::ParseInt(parts[2]);
            Points = Text::ParseInt(parts[3]);
        }

        void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex) override {
            UpdateFrom(event, _spawnIndex, true);
        }

        void UpdateFrom(MLHook::PendingEvent@ event, uint _spawnIndex, bool callSuper) override {
            auto priorCpCount = CpCount;
            auto priorNbRespawns = NbRespawnsRequested;
            uint priorStartTime = StartTime;

            if (callSuper) MLFeed::PlayerCpInfo_V2::UpdateFrom(event, _spawnIndex);

            auto parts = string(event.data[5]).Split(",");
            // sometimes on respawn, a few frames later the respawn count decreases by 1 then increases again shortly after
            // so just take the max b/c when it resets to zero we'll reset it differently.
            NbRespawnsRequested = Math::Max(NbRespawnsRequested, Text::ParseUInt(parts[0]));
            StartTime = Text::ParseUInt(parts[1]);

            bool raceReset = StartTime > priorStartTime;
            bool didRespawn = NbRespawnsRequested > priorNbRespawns;
            bool cpsChanged = CpCount != priorCpCount;
            // bool isFinished = BestRaceTimes !is null && BestRaceTimes.Length > 0 && CpCount == BestRaceTimes.Length;

            if (raceReset) {
                NbRespawnsRequested = 0;
                LastRespawnCheckpoint = 0;
                LastRespawnRaceTime = 0;
                TimeLostToRespawns = 0;
                ZeroIntArray(timeLostToRespawnsByCp);
                ZeroIntArray(nbRespawnsByCp);
                ZeroIntArray(respawnTimes);
                timeLostToRespawnsByCp.Resize(cpTimes.Length);
                nbRespawnsByCp.Resize(cpTimes.Length);
                respawnTimes.Resize(0);
            } else {
                timeLostToRespawnsByCp.Resize(cpTimes.Length);
                nbRespawnsByCp.Resize(cpTimes.Length);
                if (cpsChanged) {
                    timeLostToRespawnsByCp[CpCount] = 0;
                    nbRespawnsByCp[CpCount] = 0;
                    if (CpCount > 0) {
                        // update latency estimate
                        float lag = float(CurrentRaceTimeRaw - LastCpTime); // should be 0 if instant, or like 1 frame
                        auto n = Math::Min(9., lagDataPoints);
                        latencyEstimate = (latencyEstimate * n + lag) / (n + 1.); // simple exp/moving average type thing
                        lagDataPoints += 1;
                    }
                }
                if (didRespawn) {
                    // if we respawn at the start of the race (and it isn't a restart) then the car moves instantly
                    int respawnOverhead = CpCount == 0 ? 0 : 1000;
                    // lag is accounted for in CurrentRaceTime
                    int newTimeLost = respawnOverhead + Math::Max(0, CurrentRaceTime - LastCpTime);
                    LastRespawnRaceTime = respawnOverhead + CurrentRaceTime;
                    LastRespawnCheckpoint = CpCount;
                    TimeLostToRespawns -= timeLostToRespawnsByCp[CpCount];
                    timeLostToRespawnsByCp[CpCount] = newTimeLost;
                    TimeLostToRespawns += newTimeLost;
                    nbRespawnsByCp[CpCount] += 1;
                    respawnTimes.InsertLast(CurrentRaceTime);
                }
            }
        }

        // Does the player's CP count indicate they are finished? This should work with a forced number of laps
        bool get_IsFinished() const override {
            return this.CpCount == int(theHook.CPsToFinish);
        }
    }

    class HookRaceStatsEvents : MLFeed::HookRaceStatsEventsBase_V4 {
        // props defined in HookRaceStatsEventsBase

        // expanded props
        dictionary bestPlayerTimes;

        //
        MLHook::PendingEvent@[] incoming_msgs;

        HookRaceStatsEvents() {
            super("RaceStats");
        }

        void MainCoro() {
            sleep(50);
            MLHook::Queue_MessageManialinkPlayground("RaceStats", {"SendAllPlayerStates"});
            while (true) {
                yield();
                if (incoming_msgs.Length > 0) UpdateNonce++;
                for (uint i = 0; i < incoming_msgs.Length; i++) {
                    ProcessMsg(incoming_msgs[i]);
                }
                incoming_msgs.RemoveRange(0, incoming_msgs.Length);
                if (lastMap != CurrentMap) {
                    lastMap = CurrentMap;
                    OnMapChange();
                }
                UpdateServerTime();
            }
        }

        void UpdateServerTime() {
            theHook.Rules_GameTime = -1;
            theHook.Rules_StartTime = -1;
            theHook.Rules_EndTime = -1;
            auto app = cast<CGameManiaPlanet>(GetApp());
            if (app.Network.PlaygroundInterfaceScriptHandler is null) return;
            theHook.Rules_GameTime = app.Network.PlaygroundInterfaceScriptHandler.GameTime;
            auto cp = cast<CSmArenaClient>(app.CurrentPlayground);
            if (cp is null || cp.Arena is null || cp.Arena.Rules is null) return;
            theHook.Rules_StartTime = cp.Arena.Rules.RulesStateStartTime;
            theHook.Rules_EndTime = cp.Arena.Rules.RulesStateEndTime;
        }

        void ProcessMsg(MLHook::PendingEvent@ event) {
            if (event is null) return;
            try {
                if (event.type.EndsWith("_PlayerLeft")) {
                    // update active player list
                    UpdatePlayerLeft(event);
                } else if (event.type.EndsWith("_PlayerCP")) {
                    UpdatePlayer(event);
                } else if (event.type.EndsWith("_MatchKeyPair")) {
                    ProcessMatchKP(event);
                } else if (event.type.EndsWith("_PlayerRaceTimes")) {
                    UpdatePlayerRaceTimes(event);
                } else if (event.type.EndsWith("_PlayerInfo")) {
                    // skip, could update tho.
                } else if (event.type.EndsWith("_COTDQualiInfo")) {
                    UpdateQualiInfo(event);
                } else if (event.type.EndsWith("_LapsNb")) {
                    UpdateLapsNb(event);
                } else {
                    warn("race stats: unknown event type: " + event.type);
                }
            } catch {
                warn("HookRaceStatsEvents::ProcessMsg: Got exception processing incoming event ("+event.type+"): " + getExceptionInfo());
            }
        }

        void OnEvent(MLHook::PendingEvent@ event) override {
            incoming_msgs.InsertLast(event);
        }

        _PlayerCpInfo@ _GetPlayer(const string &in name) const {
            return cast<_PlayerCpInfo>(_GetPlayer_V4(name));
        }

        array<MLFeed::PlayerCpInfo_V4@>@ get_Players() const override {
            return RaceFeed::g_playerCpInfos;
        }

        /* main functionality logic */

        void ProcessMatchKP(MLHook::PendingEvent@ event) {
            if (event.data.Length < 2) {
                warn("race stats KP not enough data");
                return;
            }
            string key = event.data[0];
            if (key == "PlayerScore") UpdatePlayerScore(event);
            else warn("Unknown race status match kp: " + key + " w value: " + event.data[1]);
        }

        void UpdatePlayerScore(MLHook::PendingEvent@ evt) {
            auto @parts = string(evt.data[1]).Split(",");
            auto player = _GetPlayer(parts[0]);
            if (player is null) {
                warn("Got update player score for a nonexistant player: " + parts[0]);
                return;
            }
            bool isNew = player.TeamNum < 0;
            auto oldTeam = player.TeamNum;
            player.UpdateScoreFrom(parts);
            if (oldTeam != player.TeamNum) {
                teamsFeed.UpdateTeamsPopulation(oldTeam, player.TeamNum);
            }
        }

        void UpdatePlayer(MLHook::PendingEvent@ event) {
            uint spawnIx = SpawnCounter;
            string name = event.data[0];
            _PlayerCpInfo@ player;
            bool hadPlayer = latestPlayerStats.Get(name, @player);
            if (hadPlayer) {
                player.UpdateFrom(event, spawnIx);
            } else {
                @player = _PlayerCpInfo(event, spawnIx);
                AfterCreatedNewPlayer(player);
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
            DuplicateArraysForVersion1();
        }

        // called from _PlayerCpInfo when created from CSmPlayer
        void AfterCreatedNewPlayer(_PlayerCpInfo@ player) {
            trace('After create new player: ' + player.Name);
            @latestPlayerStats[player.name] = player;
            _SortedPlayers_Race.InsertLast(player);
            _SortedPlayers_TimeAttack.InsertLast(player);
            _SortedPlayers_Race_Respawns.InsertLast(player);
            player.raceRank = _SortedPlayers_Race.Length;
            player.taRank = _SortedPlayers_TimeAttack.Length;
            player.raceRespawnRank = _SortedPlayers_Race_Respawns.Length;
            player.FieldsUpdated = MLFeed::PlayerUpdateFlags(player.FieldsUpdated | MLFeed::PlayerUpdateFlags::AnyRaceRank);
        }

        void UpdatePlayerPosition(MLFeed::PlayerCpInfo_V2@ player) {
            // when a player is updated, they usually only go up or down by a few places at most.
            UpdatePlayerInSortedPlayersWithMethod(player, _SortedPlayers_TimeAttack, LessPlayers(lessTimeAttack), MLFeed::RankType::TimeAttack);
            UpdatePlayerInSortedPlayersWithMethod(player, _SortedPlayers_Race, LessPlayers(lessRace), MLFeed::RankType::Race);
            UpdatePlayerInSortedPlayersWithMethod(player, _SortedPlayers_Race_Respawns, LessPlayers(lessRaceRespawn), MLFeed::RankType::RaceRespawns);
        }

        void UpdatePlayerInSortedPlayersWithMethod(MLFeed::PlayerCpInfo_V2@ player, array<MLFeed::PlayerCpInfo_V2@>@ sorted, LessPlayers@ lessFunc, MLFeed::RankType rt) {
            uint ix = sorted.FindByRef(player);
            MLFeed::PlayerCpInfo_V2@ tmp;
            if (ix >= sorted.Length) return;
            // improving in rank
            while (ix > 0 && lessFunc(player, sorted[ix - 1])) {
                // swap these players
                @tmp = sorted[ix - 1];
                @sorted[ix - 1] = player;
                @sorted[ix] = tmp;
                ix--;
                player.ModifyRank(MLFeed::Dir::Down, rt);
                tmp.ModifyRank(MLFeed::Dir::Up, rt);
            }
            // necessary when race sorted but not everyone gets reset at the same time
            while (ix < sorted.Length - 1 && lessFunc(sorted[ix + 1], player)) {
                // swap these players
                @tmp = sorted[ix + 1];
                @sorted[ix + 1] = player;
                @sorted[ix] = tmp;
                ix++;
                player.ModifyRank(MLFeed::Dir::Up, rt);
                tmp.ModifyRank(MLFeed::Dir::Down, rt);
            }
        }

        void FixRanksRace() {
            for (uint i = 0; i < _SortedPlayers_Race.Length; i++) {
                _SortedPlayers_Race[i].raceRank = i + 1;
            }
        }

        void FixRanksRaceRespawns() {
            for (uint i = 0; i < _SortedPlayers_Race_Respawns.Length; i++) {
                _SortedPlayers_Race_Respawns[i].raceRespawnRank = i + 1;
            }
        }

        void FixRanksTimeAttack() {
            for (uint i = 0; i < _SortedPlayers_TimeAttack.Length; i++) {
                _SortedPlayers_TimeAttack[i].taRank = i + 1;
            }
        }

        // a player left the server
        void UpdatePlayerLeft(MLHook::PendingEvent@ event) {
            string name = event.data[0];
            if (!latestPlayerStats.Exists(name)) return;
            auto player = GetPlayer_V2(name);
            OnPlayerLeft(player);
        }

        void OnPlayerLeft(const MLFeed::PlayerCpInfo_V2@ player) {
            if (player !is null) {
                trace('removing: ' + player.name);
                uint ix = _SortedPlayers_Race.FindByRef(player);
                if (ix >= 0) _SortedPlayers_Race.RemoveAt(ix);
                FixRanksRace();
                ix = _SortedPlayers_TimeAttack.FindByRef(player);
                if (ix >= 0) _SortedPlayers_TimeAttack.RemoveAt(ix);
                FixRanksTimeAttack();
                ix = _SortedPlayers_Race_Respawns.FindByRef(player);
                if (ix >= 0) _SortedPlayers_Race_Respawns.RemoveAt(ix);
                FixRanksRaceRespawns();
                latestPlayerStats.Delete(player.Name);
            }
            DuplicateArraysForVersion1();
        }

        // got best times for a player
        void UpdatePlayerRaceTimes(MLHook::PendingEvent@ event) {
            // [name, current cp times, best cp times, best lap times]
            string name = event.data[0];

            auto currentCpsParts = string(event.data[1]).Split(",");
            auto bestTimesParts = string(event.data[2]).Split(",");
            auto bestLapTimesParts = string(event.data[3]).Split(",");
            bestPlayerTimes[name] = array<uint>();  // re-init this always so that we don't auto update if someone has a reference to old times
            uint[]@ playersTimes = cast<uint[]>(bestPlayerTimes[name]);
            uint[] bestLapTimes = array<uint>(bestLapTimesParts.Length);
            playersTimes.Resize(bestTimesParts.Length);
            for (uint i = 0; i < bestTimesParts.Length; i++) {
                playersTimes[i] = Text::ParseUInt(bestTimesParts[i]);
            }
            for (uint i = 0; i < bestLapTimesParts.Length; i++) {
                bestLapTimes[i] = Text::ParseUInt(bestLapTimesParts[i]);
            }
            auto player = _GetPlayer_V3(name);
            if (player !is null) {
                @player.BestRaceTimes = playersTimes;
                @player.BestLapTimes = bestLapTimes;
                for (uint i = 0; i < currentCpsParts.Length; i++) {
                    // offset by 1 b/c there's no 0th cp included.
                    auto i2 = i + 1;
                    if (i2 >= player.cpTimes.Length) break;
                    player.cpTimes[i2] = Text::ParseInt(currentCpsParts[i]);
                }
            }
            auto player_v4 = cast<MLFeed::PlayerCpInfo_V4>(player);
            if (player_v4 !is null) {
                player_v4.CurrentLap = player.CpCount / (CpCount + 1) + 1;
            }
        }

        private array<uint> _emptyUintArray;
        const array<uint>@ GetPlayersBestTimes(const string &in playerName) {
            if (!latestPlayerStats.Exists(playerName)) {
                return _emptyUintArray;
            }
            auto player = _GetPlayer_V2(playerName);
            if (player is null || player.BestRaceTimes is null) return _emptyUintArray;
            return player.BestRaceTimes;
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

        void UpdateLapsNb(MLHook::PendingEvent@ event) {
            if (event.data.Length < 1) {
                warn("UpdateLapsNb got 0 length event");
                return;
            }
            LapsNb = Text::ParseInt(event.data[0]);
            if (LapsNb == 0) LapsNb = 1;
        }
        void UpdateQualiInfo(MLHook::PendingEvent@ event) {
            if (event.data.Length != 6) {
                warn("UpdateQualiInfo got bad event data length: " + event.data.Length);
                return;
            }
            COTDQ_LocalRaceTime = Text::ParseInt(event.data[0]);
            COTDQ_APIRaceTime = Text::ParseInt(event.data[1]);
            COTDQ_Rank = Text::ParseInt(event.data[2]);
            COTDQ_QualificationsJoinTime = Text::ParseInt(event.data[3]);
            COTDQ_QualificationsProgress = MLFeed::QualificationStage(Text::ParseInt(event.data[4]));
            COTDQ_IsSynchronizingRecord = event.data[5] == "True";
            COTDQ_UpdateNonce++;
        }

        void OnMapChange() {
            ResetState();
            if (CurrentMap != "") {
                startnew(CoroutineFunc(SetCheckpointCount));
            }
        }

        void ResetState() {
            print('reset state');
            UpdateNonce++;
            bestPlayerTimes.DeleteAll();
            latestPlayerStats.DeleteAll();
            this.CpCount = 0;
            this.LapCount = 0;
            this.LapsNb = 0;
            this.Rules_EndTime = 0;
            this.Rules_StartTime = 0;
            this.Rules_GameTime = 0;
            // sorted players
            _SortedPlayers_Race.Resize(0);
            _SortedPlayers_TimeAttack.Resize(0);
            _SortedPlayers_Race_Respawns.Resize(0);
            DuplicateArraysForVersion1();
            RaceFeed::ResetState();
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

        string get_GUIPlayerName() {
            auto cp = GetApp().CurrentPlayground;
            if (cp is null) return "";
            if (cp.GameTerminals.Length < 1) return "";
            auto term = cp.GameTerminals[0];
            if (term.GUIPlayer is null) return "";
            return term.GUIPlayer.User.Name;
        }


        void DuplicateArraysForVersion1() {
            sortedPlayers_Race.Resize(SortedPlayers_Race.Length);
            sortedPlayers_TimeAttack.Resize(SortedPlayers_TimeAttack.Length);
            for (uint i = 0; i < sortedPlayers_Race.Length; i++) {
                @sortedPlayers_Race[i] = SortedPlayers_Race[i];
                @sortedPlayers_TimeAttack[i] = SortedPlayers_TimeAttack[i];
            }
        }

        int get_LastRecordTime() const override {
            if (recordHook is null) return -1;
            return recordHook.LastRecordTime;
        }
    }
}

string get_CurrentMap() {
    auto map = GetApp().RootMap;
    if (map is null) return "";
    // return map.EdChallengeId;
    return map.MapInfo.MapUid;
}

void ZeroIntArray(int[]@ arr) {
    for (uint i = 0; i < arr.Length; i++) {
        arr[i] = 0;
    }
}
