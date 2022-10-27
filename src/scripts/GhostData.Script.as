const string GHOSTDATA_SCRIPT_TXT = """
declare Text G_PreviousMapUid;

// logging function, should be "MLHook_LogMe_" + PageUID
Void MLHookLog(Text msg) {
    SendCustomEvent("MLHook_LogMe_GhostData", [msg]);
}

/// Convert a C++ array to a script array
Integer[] ToScriptArray(Integer[] _Array) {
	return _Array;
}

Void CheckMapChange() {
    if (Map != Null && Map.MapInfo.MapUid != G_PreviousMapUid) {
        G_PreviousMapUid = Map.MapInfo.MapUid;
    }
}

Void CheckIncoming() {
    declare Text[][] MLHook_Inbound_GhostData for ClientUI;
    foreach (Event in MLHook_Inbound_GhostData) {
        if (Event[0] == "SendAllPlayerStates") {
            // InitialSend();
        } else {
            MLHookLog("Skipped unknown incoming event: " ^ Event);
            continue;
        }
        MLHookLog("Processed Incoming Event: "^Event[0]);
    }
    MLHook_Inbound_GhostData = [];
}

declare Boolean[Ident] SavedGhosts;

Void CheckGhostsCPData() {
    /* there is a remote variable that is used for some game modes. Not useful for us tho it seems.

    // declare netwrite Integer[][] Net_Race_Checkpoint_GhostsTimes for UI;
    // declare Integer NbGhosts = Net_Race_Checkpoint_GhostsTimes.count;
    // if (NbGhosts > 0) {
    //     MLHookLog("GhostTimes poplated with " ^ NbGhosts ^ " ghosts.");
    //     foreach (gIx => gTimes in Net_Race_Checkpoint_GhostsTimes) {
    //         if (gTimes.count == 0) {
    //             MLHookLog("Ghost with no CPs: " ^ gIx);
    //         } else {
    //             MLHookLog("Ghost " ^ gIx ^ " cp times: " ^ gTimes);
    //         }
    //     }
    // } else {
    //     MLHookLog("Got no ghost data from Net_Race_Checkpoint_GhostsTimes");
    // }
    */
    declare Integer NbGhosts = DataFileMgr.Ghosts.count;
    MLHookLog("DataFileMgr.Ghosts poplated with " ^ NbGhosts ^ " ghosts.");
    foreach (Ghost in DataFileMgr.Ghosts) {
        if (!SavedGhosts.existskey(Ghost.Id)) {
            SavedGhosts[Ghost.Id] = True;
            DataFileMgr.Replay_Save("test-" ^ Now ^ "-" ^ Ghost.Nickname ^ "-" ^ Ghost.Result.Time ^ ".Replay.gbx", Map, Ghost);
        }
        declare Integer[] CPs = ToScriptArray(Ghost.Result.Checkpoints);
        declare Integer GhostCpCount = CPs.count;
        if (GhostCpCount == 0) {
            MLHookLog("Ghost with no CPs: " ^ Ghost.Id);
        } else {
            MLHookLog("Ghost cp times: " ^ ToScriptArray(CPs));
        }
    }
}


main() {
    declare Integer LoopCounter = 0;
    MLHookLog("Starting GhostData Feed");
    while (True) {
        yield;
        // CheckPlayers();
        LoopCounter += 1;
        if (LoopCounter > 120 && LoopCounter % 60 == 0) {
            // SendDepartedPlayers();
            // CheckMapChange();
            CheckGhostsCPData();
        }
        if (LoopCounter % 60 == 2) {
            // CheckIncoming();
        }
    }
}
""";