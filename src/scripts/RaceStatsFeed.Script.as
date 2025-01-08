const string RACESTATSFEED_SCRIPT_TXT = """
// 1 space indent due to openplanet preprocessor
 #Const C_PageUID "RaceStats"
 #Include "TextLib" as TL
 #Include "Libs/Nadeo/TMNext/TrackMania/Modes/COTDQualifications/NetShare.Script.txt" as COTDNetShare

 #Struct K_PlayerLastValues {
    Integer RoundPoints;
    Integer Points;
    Integer TeamNum;
    Integer CPCount;
    Integer RespawnsCount;
    CSmPlayer::ESpawnStatus SpawnStatus;
    Integer BestTime;
    Integer BestLapTime;

    // to cache what was updated
    Boolean UpdatePoints;
    Boolean UpdateCPs;
    Boolean UpdateBestTimes;
 }

declare Ident G_PreviousMapId;
declare Boolean G_LastWarmupActive;
declare Integer G_CWET;

// logging function, should be "MLHook_LogMe_" + PageUID
Void MLHookLog(Text _Msg) {
    SendCustomEvent("MLHook_LogMe_" ^ C_PageUID, [_Msg]);
}

Void MLHookUpdateKP(Text Key, Text Value) {
    SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_MatchKeyPair", [Key, Value]);
    // MLHookLog("MatchKeyPair: " ^ [Key, Value]);
}

Integer SpawnStatusToUint(CSmPlayer::ESpawnStatus status) {
    switch (status) {
        case CSmPlayer::ESpawnStatus::NotSpawned: {
            return 0;
        }
        case CSmPlayer::ESpawnStatus::Spawning: {
            return 1;
        }
        case CSmPlayer::ESpawnStatus::Spawned: {
            return 2;
        }
        default: {}
    }
    return 0;
}

Integer GetBestRaceTime(CSmPlayer Player) {
    if (Player == Null || Player.Score == Null) return -1;
    declare BrCount = Player.Score.BestRaceTimes.count;
    if (BrCount == 0) return -1;
    declare BrTime = Player.Score.BestRaceTimes[BrCount - 1];
    // if (Player.RaceWaypointTimes.count == BrCount) {
    //     declare RwTime = Player.RaceWaypointTimes[BrCount - 1];
    //     if (RwTime < BrTime) return RwTime;
    // }
    return BrTime;
}

// note: lap times are measured with 0 being the start of the lap
Integer GetBestLapTime(CSmPlayer Player) {
    if (Player == Null || Player.Score == Null) return -1;
    declare BrCount = Player.Score.BestLapTimes.count;
    if (BrCount == 0) return -1;
    return Player.Score.BestLapTimes[BrCount - 1];
}

// Bool IsFinished(CSmPlayer Player) {
//     declare NbCPs = Player.Score.BestRaceTimes.count;
// }

// Integer[] GetBestRaceTimes(CSmPlayer Player) {
//     if (Player == Null || Player.Score == Null) return [];
//     return Player.Score.BestRaceTimes;
// }


declare Ident[] G_LastKnownPlayers;

// send a players that left every now and then.
Void SendDepartedPlayers() {
    declare Boolean[Ident] CurrentPlayers;
    declare Ident[] CurrPlayerIds;
    foreach (Player in Players) {
        if (Player.Score == Null) continue;
        CurrentPlayers[Player.User.Id] = True;
        CurrPlayerIds.add(Player.User.Id);
    }
    foreach (PlayerLoginId in G_LastKnownPlayers) {
        if (CurrentPlayers.existskey(PlayerLoginId)) continue;
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_PlayerLeft", [""^PlayerLoginId]);
    }
    G_LastKnownPlayers = CurrPlayerIds;
    // G_LastKnownPlayers.clear();
    // foreach (PlayerId in CurrPlayerIds) {
    //     G_LastKnownPlayers.add(PlayerId);
    // }
}


Text[] CPTimesStr(Integer[] Checkpoints) {
    declare Text[] Ret = [];
    foreach (t in Checkpoints) {
        Ret.add("" ^ t);
    }
    return Ret;
}


// send all players best times
Void _SendPlayerTimes(CSmPlayer Player) {
    if (Player.Score == Null) return;
    declare Text Name = Player.User.Name;
    declare Text RaceTimes = TL::Join(",", CPTimesStr(Player.RaceWaypointTimes));
    declare Text BestTimes = TL::Join(",", CPTimesStr(Player.Score.BestRaceTimes));
    declare Text BestLapTimes = TL::Join(",", CPTimesStr(Player.Score.BestLapTimes));
    // declare NbCurrCheckpoints = Player.RaceWaypointTimes.count;
    // if (NbCurrCheckpoints > 0
    //     && NbCurrCheckpoints == Player.Score.BestRaceTimes.count
    //     && Player.RaceWaypointTimes[NbCurrCheckpoints - 1] < Player.Score.BestRaceTimes[NbCurrCheckpoints - 1]
    // ) {
    //     // BestRaceTimes just not updated yet, so return current CP times instead
    //     BestTimes = RaceTimes;
    // }
    // we used to send race times at ix=1 but don't anymore, so zero it
    SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_PlayerRaceTimes", [Name, RaceTimes, BestTimes, BestLapTimes]);
}



declare K_PlayerLastValues[Ident] LastPlayerValues;



declare Integer[Ident] LastPlayerRoundPoints;
declare Integer[Ident] LastPlayerPoints;
declare Integer[Ident] LastPlayerTeams;

Void CheckPlayerPoints() {
    foreach (Player in Players) {
        if (Player.Score != Null) {
            declare CSmScore Score <=> Player.Score;
            declare RPointsChanged = !LastPlayerRoundPoints.existskey(Score.Id) || LastPlayerRoundPoints[Score.Id] != Score.RoundPoints;
            declare PointsChanged = !LastPlayerPoints.existskey(Score.Id) || LastPlayerPoints[Score.Id] != Score.Points;
            declare TeamChanged = !LastPlayerTeams.existskey(Score.Id) || LastPlayerTeams[Score.Id] != Score.TeamNum;
            if (RPointsChanged || PointsChanged || TeamChanged) {
                LastPlayerRoundPoints[Score.Id] = Score.RoundPoints;
                LastPlayerPoints[Score.Id] = Score.Points;
                LastPlayerTeams[Score.Id] = Score.TeamNum;
                MLHookUpdateKP("PlayerScore", TL::Join(",", [Player.User.Name, ""^Score.TeamNum, ""^Score.RoundPoints, ""^Score.Points]));
            }
        }
    }
}

Void SendUpdate_PlayerPoints(CSmPlayer _Player, K_PlayerLastValues _LastValues) {
    if (_Player == Null || _Player.Score == Null) return;
    if (!_LastValues.UpdatePoints) return;
    declare CSmScore Score <=> _Player.Score;
    MLHookUpdateKP("PlayerScore", TL::Join(",", [_Player.User.Name, ""^Score.TeamNum, ""^Score.RoundPoints, ""^Score.Points]));
}


// we only want to send info when a player's CP count changes.
declare Integer[Ident] LastCPCounts;
declare Integer[Ident] LastBestTimes;
declare Integer[Ident] LastBestLapTimes;
declare Integer[Ident] LastRespawnsCount;
declare CSmPlayer::ESpawnStatus[Ident] LastSpawn;
declare Integer MostCPsSeen;
declare Integer LastKnownLapsNb;

Boolean _SendPlayerStats(CSmPlayer Player, Boolean Force) {
    if (Player == Null || Player.Score == Null || Player.User == Null) return False;
    // tuningstart();
    declare Text Name = Player.User.Name;
    declare Ident PlayerId = Player.Score.Id;
    declare Integer CPCount = Player.RaceWaypointTimes.count;
    declare Integer RespawnsCount = Player.Score.NbRespawnsRequested;
    declare Integer BestTime = GetBestRaceTime(Player);
    declare Integer BestLapTime = GetBestLapTime(Player);
    if (CPCount > MostCPsSeen) {
        MostCPsSeen = CPCount;
    }
    // check for changes
    declare Boolean SpawnChanged = LastSpawn.existskey(PlayerId) && Player.SpawnStatus != LastSpawn[PlayerId];
    declare Boolean CpsChanged = LastCPCounts.existskey(PlayerId) && CPCount != LastCPCounts[PlayerId];
    declare Boolean RespawnsChanged = LastRespawnsCount.existskey(PlayerId) && RespawnsCount != LastRespawnsCount[PlayerId];
    declare Boolean BestTimeChanged = LastBestTimes.existskey(PlayerId) && BestTime != LastBestTimes[PlayerId];
    declare Boolean BestLapTimeChanged = LastBestLapTimes.existskey(PlayerId) && BestLapTime != LastBestLapTimes[PlayerId];

    // update if there are changes or the update is forced.
    declare Boolean WillSendEvent = Force || SpawnChanged || CpsChanged || RespawnsChanged || BestTimeChanged || BestLapTimeChanged;
    // if there are no changes, return early.
    if (!WillSendEvent) { return False; }

    if (WillSendEvent) {
        declare Text LatestCPTime = "";
        if (CPCount > 0) {
            LatestCPTime = ""^Player.RaceWaypointTimes[CPCount - 1];
        }
        // events should be prefixed with "MLHook_Event_" + PageUID.
        // Suffixes can be applied if multiple types of events are sent.
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_PlayerCP", [Name, ""^CPCount, LatestCPTime, ""^BestTime, ""^SpawnStatusToUint(Player.SpawnStatus), ""^RespawnsCount^","^Player.StartTime]);
    }
    // if (Force || )
    if (Force || BestTimeChanged || BestLapTimeChanged) {
        _SendPlayerTimes(Player);
    }
    // update last spawn and cp count always
    LastCPCounts[PlayerId] = CPCount;
    LastSpawn[PlayerId] = Player.SpawnStatus;
    LastRespawnsCount[PlayerId] = RespawnsCount;
    LastBestTimes[PlayerId] = BestTime;
    LastBestLapTimes[PlayerId] = BestLapTime;
    return WillSendEvent;
    // tuningend();
}

Text GetLatestCpTimeStr(CSmPlayer _Player) {
    declare Integer CPCount = _Player.RaceWaypointTimes.count;
    if (CPCount == 0) return "";
    return ""^_Player.RaceWaypointTimes[CPCount - 1];

}

Boolean SendPlayerStats2(CSmPlayer _Player, Boolean _Force) {
    declare K_PlayerLastValues LastValues = LastPlayerValues[_Player.Score.Id];
    declare Boolean SentEvent = False;
    if (LastValues.UpdateCPs || _Force) {
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_PlayerCP",
            [_Player.User.Name, ""^LastValues.CPCount, GetLatestCpTimeStr(_Player),
                ""^LastValues.BestTime, ""^SpawnStatusToUint(LastValues.SpawnStatus),
                ""^LastValues.RespawnsCount^","^_Player.StartTime]);
        SentEvent = True;
    }
    if (LastValues.UpdateBestTimes || _Force) {
        _SendPlayerTimes(_Player);
        SentEvent = True;
    }
    if (LastValues.UpdatePoints || _Force) {
        SendUpdate_PlayerPoints(_Player, LastValues);
        SentEvent = True;
    }
    return SentEvent;
}


declare Int2[Ident] LastRaceProgression;
declare Text G_RaceProgEvent;

Void _SendPlayerRaceProg(CSmScore Score) {
    if (TL::Length(G_RaceProgEvent) == 0) {
        G_RaceProgEvent = "MLHook_Event_" ^ C_PageUID ^ "_PlayerRaceProgression";
    }
    declare netread Int2 Net_TMGame_ScoresTable_RaceProgression for Score = <0, 0>;
    declare Boolean Changed = !LastRaceProgression.existskey(Score.Id) || Net_TMGame_ScoresTable_RaceProgression != LastRaceProgression[Score.Id];
    if (Changed) {
        LastRaceProgression[Score.Id] = Net_TMGame_ScoresTable_RaceProgression;
        SendCustomEvent(G_RaceProgEvent, [Score.User.Name, ""^Net_TMGame_ScoresTable_RaceProgression.X, ""^Net_TMGame_ScoresTable_RaceProgression.Y]);
    }
}


Void _SendPlayerInfos(CSmPlayer Player) {
    SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_PlayerInfo", [Player.User.Name, Player.User.Login, Player.User.WebServicesUserId]);
}


Boolean IsCotdQuali() {
    return Playground.ServerInfo.ModeName == "TM_COTDQualifications_Online";
}

declare Integer LastLocalRaceTime;
declare Integer LastAPIRaceTime;
declare Integer LastRank;
declare Integer LastQualificationsJoinTime;
declare Integer LastQualificationsProgress;
declare Boolean LastIsSynchronizingRecord;

Void _SendCOTDQuali() {
    if (!IsCotdQuali()) return;
    if (
        COTDNetShare::GetMyLocalRaceTime(UI) != LastLocalRaceTime ||
        COTDNetShare::GetMyAPIRaceTime(UI) != LastAPIRaceTime ||
        COTDNetShare::GetMyRank(UI) != LastRank ||
        COTDNetShare::GetMyQualificationsJoinTime(UI) != LastQualificationsJoinTime ||
        COTDNetShare::GetQualificationsProgress(Teams[0]) != LastQualificationsProgress ||
        COTDNetShare::IsSynchronizingRecord(UI) != LastIsSynchronizingRecord
    ) {
        LastLocalRaceTime = COTDNetShare::GetMyLocalRaceTime(UI);
        LastAPIRaceTime = COTDNetShare::GetMyAPIRaceTime(UI);
        LastRank = COTDNetShare::GetMyRank(UI);
        LastQualificationsJoinTime = COTDNetShare::GetMyQualificationsJoinTime(UI);
        LastQualificationsProgress = COTDNetShare::GetQualificationsProgress(Teams[0]);
        LastIsSynchronizingRecord = COTDNetShare::IsSynchronizingRecord(UI);
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_COTDQualiInfo", [
            ""^LastLocalRaceTime,
            ""^LastAPIRaceTime,
            ""^LastRank,
            ""^LastQualificationsJoinTime,
            ""^LastQualificationsProgress,
            ""^LastIsSynchronizingRecord
        ]);
        MLHookLog("COTD: " ^ [
            ""^LastLocalRaceTime,
            ""^LastAPIRaceTime,
            ""^LastRank,
            ""^LastQualificationsJoinTime,
            ""^LastQualificationsProgress,
            ""^LastIsSynchronizingRecord
        ]);
    }
}

Void _CheckLapsNb() {
    declare netread Integer Net_Race_Helpers_LapsNb for Teams[0] = -1;
    if (LastKnownLapsNb != Net_Race_Helpers_LapsNb) {
        LastKnownLapsNb = Net_Race_Helpers_LapsNb;
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_LapsNb", [
            ""^LastKnownLapsNb
        ]);
    }
}

// to start with we want to send all data.
Void InitialSend() {
    foreach (Player in Players) {
        _SendPlayerStats(Player, True);
        _SendPlayerInfos(Player);
    }
    MLHookLog("Completed: InitialSend");
}

K_PlayerLastValues New_K_PlayerLastValues(CSmPlayer _Player) {
    // declare K_PlayerLastValues Ret;
    // Ret.RoundPoints = _Player.Score.RoundPoints;
    // Ret.Points = _Player.Score.Points;
    // Ret.TeamNum = _Player.Score.TeamNum;
    // Ret.CPCount = _Player.RaceWaypointTimes.count;
    // Ret.RespawnsCount = _Player.Score.NbRespawnsRequested;
    // Ret.SpawnStatus = _Player.SpawnStatus;
    // Ret.BestTime = GetBestRaceTime(_Player);
    // Ret.BestLapTime = GetBestLapTime(_Player);
    // Ret.UpdatePoints = False;
    // Ret.UpdateCPs = False;
    // Ret.UpdateBestTimes = False;
    return K_PlayerLastValues {
        RoundPoints = _Player.Score.RoundPoints,
        Points = _Player.Score.Points,
        TeamNum = _Player.Score.TeamNum,
        CPCount = _Player.RaceWaypointTimes.count,
        RespawnsCount = _Player.Score.NbRespawnsRequested,
        SpawnStatus = _Player.SpawnStatus,
        BestTime = GetBestRaceTime(_Player),
        BestLapTime = GetBestLapTime(_Player),
        UpdatePoints = True,
        UpdateCPs = True,
        UpdateBestTimes = True
    };
}

Boolean ShouldUpdatePlayer(CSmPlayer _Player) {
    if (_Player == Null || _Player.Score == Null) return False;
    // if new, create and return true
    if (!LastPlayerValues.existskey(_Player.Score.Id)) {
        LastPlayerValues[_Player.Score.Id] = New_K_PlayerLastValues(_Player);
        return True;
    }

    // get last values and compare
    declare K_PlayerLastValues LastValues = LastPlayerValues[_Player.Score.Id];
    // if (LastValues == Null) {
    //     LastPlayerValues[_Player.Score.Id] = New_K_PlayerLastValues(_Player);
    //     return True;
    // }
    // from CheckPlayerPoints
    LastValues.UpdatePoints = LastValues.Points != _Player.Score.Points || LastValues.RoundPoints != _Player.Score.RoundPoints || LastValues.TeamNum != _Player.Score.TeamNum;
    // from _SendPlayerStats
    LastValues.UpdateBestTimes = LastValues.BestTime != GetBestRaceTime(_Player)
        || LastValues.BestLapTime != GetBestLapTime(_Player);
    LastValues.UpdateCPs = LastValues.CPCount != _Player.RaceWaypointTimes.count
        || LastValues.RespawnsCount != _Player.Score.NbRespawnsRequested
        || LastValues.SpawnStatus != _Player.SpawnStatus
        || LastValues.UpdateBestTimes;

    // update values
    if (LastValues.UpdatePoints) {
        LastValues.RoundPoints = _Player.Score.RoundPoints;
        LastValues.Points = _Player.Score.Points;
        LastValues.TeamNum = _Player.Score.TeamNum;
    }
    if (LastValues.UpdateBestTimes) {
        LastValues.BestTime = GetBestRaceTime(_Player);
        LastValues.BestLapTime = GetBestLapTime(_Player);
    }
    if (LastValues.UpdateCPs) {
        LastValues.CPCount = _Player.RaceWaypointTimes.count;
        LastValues.RespawnsCount = _Player.Score.NbRespawnsRequested;
        LastValues.SpawnStatus = _Player.SpawnStatus;
    }

    if (LastValues.UpdatePoints || LastValues.UpdateCPs || LastValues.UpdateBestTimes) {
        LastPlayerValues[_Player.Score.Id] = LastValues;
        return True;
    }
    return False;
}


Void CheckPlayers() {
    declare Integer c = 0;
    foreach (Player in Players) {
        // handles points and other stats
        if (ShouldUpdatePlayer(Player)) {
            if (SendPlayerStats2(Player, False)) {
                c += 1;
            }
        }
    }
}

Boolean IsWarmupActive(CTeam _Team) {
	declare netread Boolean Net_Race_WarmupHelpers_IsWarmupActive for _Team = False;
	return Net_Race_WarmupHelpers_IsWarmupActive;
}

Integer CurrentWarmupEndTime(CTeam _Team) {
	declare netread Integer Net_Race_WarmupHelpers_CurrentWarmUpEndTime for _Team = 0;
	return Net_Race_WarmupHelpers_CurrentWarmUpEndTime;
}


Void CheckWarmup() {
    // Net_Race_WarmupHelpers_IsWarmupActive
    if (Teams.count == 0) {
        return;
    }
    declare Integer CWET = CurrentWarmupEndTime(Teams[0]);
    declare Boolean WarmupActive = IsWarmupActive(Teams[0]);
    if (G_LastWarmupActive != WarmupActive || CWET != G_CWET) {
        G_LastWarmupActive = !G_LastWarmupActive;
        G_CWET = CWET;
        SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_Warmup", [""^G_LastWarmupActive, ""^CWET]);
    }
}

declare Integer G_LastRaceProgressionNonce;

Void CheckRaceProgression() {
    declare netread Integer Net_TMGame_ScoresTable_RaceProgressionUpdate for Teams[0] = -1;
    if (Net_TMGame_ScoresTable_RaceProgressionUpdate == G_LastRaceProgressionNonce) {
        return;
    }
    G_LastRaceProgressionNonce = Net_TMGame_ScoresTable_RaceProgressionUpdate;
    foreach (Score in Scores) {
        _SendPlayerRaceProg(Score);
    }
}


Void CheckMapChange() {
    if (Map != Null && Map.Id != G_PreviousMapId) {
        G_PreviousMapId = Map.Id;
        LastBestTimes = [];
        LastBestLapTimes = [];
        LastCPCounts = [];
        G_LastKnownPlayers = [];
        LastRespawnsCount = [];
        LastSpawn = [];
        MostCPsSeen = 0;
        LastPlayerPoints = [];
        LastPlayerRoundPoints = [];
        LastPlayerTeams = [];
        LastKnownLapsNb = -2;
        LastPlayerValues = [];
    }
}

Void CheckIncoming() {
    declare Text[][] MLHook_Inbound_RaceStats for ClientUI = [];
    foreach (Event in MLHook_Inbound_RaceStats) {
        if (Event.count > 0) {
            if (Event[0] == "SendAllPlayerStates") {
                InitialSend();
            } else {
                MLHookLog("Skipped unknown incoming event: " ^ Event);
                continue;
            }
            // MLHookLog("DEBUG Processed Incoming Event: "^Event[0]);
        } else {
            MLHookLog("WARN Skipped empty incoming event");
        }
    }
    MLHook_Inbound_RaceStats = [];
}

main() {
    G_LastWarmupActive = False;
    G_CWET = -1;
    declare Integer LoopCounter = 0;
    MLHookLog("Starting RaceStatsFeed");
    while (Players.count == 0) {
        yield;
    }
    MLHookLog("RaceStatsFeed got init players");
    yield;
    yield;
    yield;
    yield;
    InitialSend();
    MLHookLog("RaceStatsFeed did init send");
    CheckWarmup();
    // declare Integer StartTime = 0;
    // declare Integer Delta = 0;
    // declare Boolean ShouldUpdateRaceProg = False;
    declare Integer SendDepartedEvery_Frames = 60;
// #if DEV
//     SendDepartedEvery_Frames = 60;
// #endif
    while (True) {
        // if (LoopCounter % 51 == 0) {
        //     ShouldUpdateRaceProg = CurrentServerModeName == "TM_RoyalTimeAttack_Online";
        // }
        yield;
        CheckMapChange();
        CheckPlayers();
        // points sent through new last values system
        // CheckPlayerPoints();
        CheckWarmup();
        // if (ShouldUpdateRaceProg) CheckRaceProgression();
        CheckRaceProgression();

        LoopCounter += 1;
        if (LoopCounter % SendDepartedEvery_Frames == 0) {
            // costs about 0.1ms / 40 players
            SendDepartedPlayers();
        }
        if (LoopCounter % 30 == 20) {
            CheckIncoming();
            _SendCOTDQuali();
            _CheckLapsNb();
        }
    }
}
""";