const string GHOSTDATA_SCRIPT_TXT = """
// 1 space indent due to openplanet preprocessor
 #Const C_PageUID "GhostData"
 #Include "TextLib" as TL


declare Text G_PreviousMapUid;
declare Boolean MapChanged;

declare Integer LastNbGhosts;
declare Boolean[Ident] SeenGhosts;

// logging function, should be "MLHook_LogMe_" + PageUID
Void MLHookLog(Text msg) {
    SendCustomEvent("MLHook_LogMe_" ^ C_PageUID, [msg]);
}

Text[] CPTimesStr(Integer[] Checkpoints) {
    declare Text[] Ret = [];
    foreach (t in Checkpoints) {
        Ret.add("" ^ t);
    }
    return Ret;
}

Text[] CheckpointIDs(CGhost Ghost) {
    declare Text[] Ret = [];
    foreach (Id in Ghost.Result.CheckpointLandmarkIds) {
        Ret.add(""^Id);
    }
    return Ret;
}

Void SendGhostInfo(CGhost Ghost) {
    // send back: [Id.Value, Nickname, Result.Score, Result.Time, Result.Checkpoints]
    // NbRespanws always -1 (even with 3 respawns)
    declare Text[] ToSend = [""^Ghost.Id, TL::StripFormatting(Ghost.Nickname), "" ^ Ghost.Result.Score, "" ^ Ghost.Result.Time, TL::Join(",", CPTimesStr(Ghost.Result.Checkpoints))];
    // CheckpointLandmarkIds seem to always be empty
    // ToSend.add(TL::Join(",", CheckpointIDs(Ghost)));
    SendCustomEvent("MLHook_Event_" ^ C_PageUID, ToSend);
    MLHookLog("Send ghost data: " ^ ToSend);
}

Void SendGhostLeft(Ident GhostId) {
    SendCustomEvent("MLHook_Event_" ^ C_PageUID ^ "_Removed", [""^GhostId]);
    MLHookLog("Remove ghost: " ^ GhostId);
}

/// Convert a C++ array to a script array
Integer[] ToScriptArray(Integer[] _Array) {
	return _Array;
}

Void ResetState() {
    LastNbGhosts = 0;
    SeenGhosts.clear();
    // SendCustomEvent("MLHook_Event_" ^ C_PageUID, ["RESET"]);
}

Void CheckMapChange() {
    if (Map != Null && Map.MapInfo.MapUid != G_PreviousMapUid) {
        G_PreviousMapUid = Map.MapInfo.MapUid;
        MapChanged = True;
    } else {
        MapChanged = False;
    }
}

Void OnMapChange() {
    ResetState();
}

Void CheckIncoming() {
    declare Text[][] MLHook_Inbound_GhostData for ClientUI = [];
    foreach (Event in MLHook_Inbound_GhostData) {
        if (Event[0] == "RefreshGhostData") {
            ResetState();
        } else {
            MLHookLog("Skipped unknown incoming event: " ^ Event);
            continue;
        }
        MLHookLog("Processed Incoming Event: "^Event[0]);
    }
    MLHook_Inbound_GhostData = [];
}


// we'll send all ghosts info for simplicity and let angelscript figure out the rest; so don't track CPs here
Void RecordSeen(CGhost Ghost) {
    SeenGhosts[Ghost.Id] = True;
}

Boolean ShouldCacheGhost(CGhost Ghost) {
    return !SeenGhosts.existskey(Ghost.Id);
}


Void CheckGhostsCPData() {
    declare Integer NbGhosts = DataFileMgr.Ghosts.count;
    // no new ghosts if count didn't change and we've seen the first ghost in the list. seemingly, when personal ghosts are added, they are at the start, not the end.
    if (LastNbGhosts == NbGhosts && (NbGhosts == 0 || SeenGhosts.existskey(DataFileMgr.Ghosts[0].Id))) { return; }
    // figure out if we want to cache this ghost's CP times
    MLHookLog("DataFileMgr.Ghosts found " ^ (NbGhosts - LastNbGhosts) ^ " new ghosts.");
    declare Boolean GhostLeft = NbGhosts < LastNbGhosts;
    LastNbGhosts = NbGhosts;
    foreach (Ghost in DataFileMgr.Ghosts) {
        if (ShouldCacheGhost(Ghost)) {
            RecordSeen(Ghost);
            SendGhostInfo(Ghost);
        }
    }
    if (GhostLeft) {
        declare ToRemove = SeenGhosts;
        foreach (Ghost in DataFileMgr.Ghosts) {
            ToRemove.removekey(Ghost.Id);
        }
        foreach (GhostId => _Meh in ToRemove) {
            SendGhostLeft(GhostId);
            SeenGhosts.removekey(GhostId);
        }
    }
    // does not work -- might work from game script code, but not ML
    // if (Mode != Null) {
    //     MLHookLog("Mode exists");
    //     if (Mode.DataFileMgr != Null) {
    //         MLHookLog("Mode.DataFileMgr exists");
    //         MLHookLog("Mode.DataFileMgr ghosts: " ^ Mode.DataFileMgr.Ghosts.count);
    //     }
    // }
}


main() {
    MLHookLog("Starting GhostData Feed");
    while (True) {
        yield;
        CheckIncoming();
        CheckMapChange();
        if (MapChanged) OnMapChange();
        CheckGhostsCPData();
    }
}
""";