const string MLFEEDKOS_SCRIPT_TXT = """
// MLFeedKOs.Script.txt

// logging function, should be "MLHook_LogMe_" + PageUID
Void MLHookLog(Text msg) {
    SendCustomEvent("MLHook_LogMe_MLFeedKOs", [msg]);
}

Void MLHookUpdateKP(Text Key, Text Value) {
    SendCustomEvent("MLHook_Event_MLFeedKOs_MatchKeyPair", [Key, Value]);
    // MLHookLog("MatchKeyPair: " ^ [Key, Value]);
}

/**
todo: do anything with these?
declare netread Boolean Net_Knockout_KnockedOutPlayers_DisplayContent for Teams[0] = False;
declare netread Text[] Net_Knockout_KnockedOutPlayers_AccountIds for Teams[0];
declare netread Integer[] Net_Knockout_KnockedOutPlayers_Ranks for Teams[0];
declare netread Integer Net_Knockout_KnockedOutPlayers_EliminatedPlayerUpdate for Teams[0];
*/

declare Boolean[Text] ScoreLastAlive;
declare Boolean[Text] ScoreLastDNF;

Void UpdatePlayerStatus() {
    // tuningstart();
    foreach (Score in Scores) {
        if (Score == Null || Score.User == Null) continue;
        declare netread Boolean Net_Knockout_PlayerIsAlive for Score;
        declare netread Boolean Net_Knockout_DNF for Score;
        declare Text UserId = Score.User.Name;
        if (UserId == "Unnamed") continue;
        if (!ScoreLastAlive.existskey(UserId)
            || !ScoreLastDNF.existskey(UserId)
            || ScoreLastAlive[UserId] != Net_Knockout_PlayerIsAlive
            || ScoreLastDNF[UserId] != Net_Knockout_DNF) {
                // MLHookUpdatePlayerStatus(UserId, Net_Knockout_PlayerIsAlive, Net_Knockout_DNF);
                SendCustomEvent("MLHook_Event_MLFeedKOs_PlayerStatus", [UserId, ""^Net_Knockout_PlayerIsAlive, ""^Net_Knockout_DNF]);
                ScoreLastAlive[UserId] = Net_Knockout_PlayerIsAlive;
                ScoreLastDNF[UserId] = Net_Knockout_DNF;
                yield;
            }
    }
    // tuningend();
}

declare Integer Last_KOI_MapRoundNb;
declare Integer Last_KOI_MapRoundTotal;
declare Integer Last_KOI_RoundNb;
declare Integer Last_KOI_RoundTotal;
declare Integer Last_KOI_PlayersNb;
declare Integer Last_KOI_KOsNumber;
declare Integer Last_KOI_KOsMilestone;
declare Integer Last_KOI_RankingUpdate;
declare Integer Last_KOI_ServerNumber;

Void CheckRoundUpdates() {
    // tuningstart();
    declare netread Integer Net_Knockout_KnockoutInfo_MapRoundNb for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_MapRoundTotal for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_RoundNb for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_RoundTotal for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_PlayersNb for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_KOsNumber for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_KOsMilestone for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_RankingUpdate for Teams[0];
    declare netread Integer Net_Knockout_KnockoutInfo_ServerNumber for Teams[0];
    // tuningend();
    if (Last_KOI_MapRoundNb != Net_Knockout_KnockoutInfo_MapRoundNb) {
        Last_KOI_MapRoundNb = Net_Knockout_KnockoutInfo_MapRoundNb;
        MLHookUpdateKP("MapRoundNb", ""^Net_Knockout_KnockoutInfo_MapRoundNb);
    }
    if (Last_KOI_MapRoundTotal != Net_Knockout_KnockoutInfo_MapRoundTotal) {
        Last_KOI_MapRoundTotal = Net_Knockout_KnockoutInfo_MapRoundTotal;
        MLHookUpdateKP("MapRoundTotal", ""^Net_Knockout_KnockoutInfo_MapRoundTotal);
    }
    if (Last_KOI_RoundNb != Net_Knockout_KnockoutInfo_RoundNb) {
        Last_KOI_RoundNb = Net_Knockout_KnockoutInfo_RoundNb;
        MLHookUpdateKP("RoundNb", ""^Net_Knockout_KnockoutInfo_RoundNb);
    }
    if (Last_KOI_RoundTotal != Net_Knockout_KnockoutInfo_RoundTotal) {
        Last_KOI_RoundTotal = Net_Knockout_KnockoutInfo_RoundTotal;
        MLHookUpdateKP("RoundTotal", ""^Net_Knockout_KnockoutInfo_RoundTotal);
    }
    if (Last_KOI_PlayersNb != Net_Knockout_KnockoutInfo_PlayersNb) {
        Last_KOI_PlayersNb = Net_Knockout_KnockoutInfo_PlayersNb;
        MLHookUpdateKP("PlayersNb", ""^Net_Knockout_KnockoutInfo_PlayersNb);
    }
    if (Last_KOI_KOsNumber != Net_Knockout_KnockoutInfo_KOsNumber) {
        Last_KOI_KOsNumber = Net_Knockout_KnockoutInfo_KOsNumber;
        MLHookUpdateKP("KOsNumber", ""^Net_Knockout_KnockoutInfo_KOsNumber);
    }
    if (Last_KOI_KOsMilestone != Net_Knockout_KnockoutInfo_KOsMilestone) {
        Last_KOI_KOsMilestone = Net_Knockout_KnockoutInfo_KOsMilestone;
        MLHookUpdateKP("KOsMilestone", ""^Net_Knockout_KnockoutInfo_KOsMilestone);
    }
    if (Last_KOI_RankingUpdate != Net_Knockout_KnockoutInfo_RankingUpdate) {
        Last_KOI_RankingUpdate = Net_Knockout_KnockoutInfo_RankingUpdate;
        MLHookUpdateKP("RankingUpdate", ""^Net_Knockout_KnockoutInfo_RankingUpdate);
    }
    if (Last_KOI_ServerNumber != Net_Knockout_KnockoutInfo_ServerNumber) {
        Last_KOI_ServerNumber = Net_Knockout_KnockoutInfo_ServerNumber;
        MLHookUpdateKP("ServerNumber", ""^Net_Knockout_KnockoutInfo_ServerNumber);
    }
}

Void ResetAllTrackedState() {
    Last_KOI_MapRoundNb = -2;
    Last_KOI_MapRoundTotal = -2;
    Last_KOI_RoundNb = -2;
    Last_KOI_RoundTotal = -2;
    Last_KOI_PlayersNb = -2;
    Last_KOI_KOsNumber = -2;
    Last_KOI_KOsMilestone = -2;
    Last_KOI_RankingUpdate = -2;
    Last_KOI_ServerNumber = -2;
    ScoreLastAlive = [];
    ScoreLastDNF = [];
}

declare Text CurrentGameMode;
declare Boolean IsKOGameMode;

Void CheckGM() {
    CurrentGameMode = Playground.ServerInfo.ModeName;
    IsKOGameMode = CurrentGameMode == "TM_KnockoutDaily_Online"
                || CurrentGameMode == "TM_Knockout_Debug"
                || CurrentGameMode == "TM_Knockout_Online";
}

declare Text G_PreviousMapUid;

Void CheckMapChange() {
    if (Map != Null && Map.MapInfo.MapUid != G_PreviousMapUid) {
        G_PreviousMapUid = Map.MapInfo.MapUid;
        ResetAllTrackedState();
        CheckGM();
    }
}

Void CheckIncoming() {
    declare Text[][] MLHook_Inbound_MLFeedKOs for ClientUI;
    foreach (Event in MLHook_Inbound_MLFeedKOs) {
        if (Event[0] == "SetGameMode") {
            MLHookLog("Set new GameMode from AS: "^CurrentGameMode);
            // CurrentGameMode = Event[1];
            // IsKOGameMode = CurrentGameMode == "TM_KnockoutDaily_Online"
            //             || CurrentGameMode == "TM_Knockout_Debug"
            //             || CurrentGameMode == "TM_Knockout_Online";
        } else if (Event[0] == "SendAllMatchKeyPairs") {
            ResetAllTrackedState();
        } else if (Event[0] == "SendAllPlayerStates") {
            ScoreLastAlive = []; // this will trigger an update next loop
        }
        MLHookLog("processed incoming event: " ^ Event[0]);
    }
    MLHook_Inbound_MLFeedKOs = [];
}

main() {
    // tuningstart();
    // tuningmark(_("main loop"));
    CheckGM();
    // note that we yield in the main inner loop (60 frames)
    while (True) {
        // these will trigger once every 60 frames
        CheckMapChange();
        CheckGM();
        // main loop, for 60 frames
        for (I, 0, 60) {
            yield;
            CheckIncoming();
            if (IsKOGameMode) {
                CheckRoundUpdates();
                UpdatePlayerStatus();
            }
        }
    }
    // tuningend();
}
""";