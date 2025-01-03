Meta::PluginCoroutine@ listUidsAutoStarter = startnew(ListUids_Init_MLHook).WithRunContext(Meta::RunContext::AfterScripts);

void ListUids_Init_MLHook() {
    MLHook::RegisterMLHook(H_ReceiveMapUids, "ListUids_Pair");
    MLHook::RegisterMLHook(H_ReceiveMapUids, "ListUids_Clear");
    MLHook::RegisterMLHook(H_ReceiveMapUids, "ListUids_IsReqActive");
}

ListUids_MLHook@ H_ReceiveMapUids = ListUids_MLHook();
bool g_ListUid_RegisteredMl = false;

void ProcessListUidsUpdates_Loop() {
    while (true) {
        H_ReceiveMapUids.ProcessMsgs();
        yield();
    }
}

class ListUids_MLHook : MLFeed::MapListUids_Receiver {
    MLHook::PendingEvent@[] incoming_msgs;

    uint _UpdateCount = 0;
    string[] _MapList_MapUids;
    string[] _MapList_Names;
    bool _MapList_IsInProgress;

    uint64 lastCheckStart = 0;
    uint64 lastCheckEnd = 0;

    ListUids_MLHook() {
        super();
        startnew(CoroutineFunc(this._RegisterManialinkToInject));
    }

    private void _RegisterManialinkToInject() {
        if (g_ListUid_RegisteredMl) throw("ListUids_MLHook: already registered");
        g_ListUid_RegisteredMl = true;
        MLHook::InjectManialinkToPlayground("ListUids", Get_ListUids_Script_txt_Content(), true);
    }

    void OnEvent(MLHook::PendingEvent@ event) override {
        incoming_msgs.InsertLast(event);
        // ProcessMsg(event);
    }

    protected void SendListRequestToML() {
        MLHook::Queue_MessageManialinkPlayground("ListUids", {});
    }

    void ProcessMsgs() {
        if (incoming_msgs.Length == 0) return;
        for (uint i = 0; i < incoming_msgs.Length; i++) {
            ProcessMsg(incoming_msgs[i]);
        }
        incoming_msgs.RemoveRange(0, incoming_msgs.Length);
    }

    protected void ProcessMsg(MLHook::PendingEvent@ event) {
        string ty = event.type.SubStr(22); // remove MLHook_Event_ListUids_
        if (ty == "Pair") {
            if (event.data.Length != 2) {
                warn("ListUids_Pair: expected 2 data elements, got " + event.data.Length);
                return;
            }
            auto uid = string(event.data[0]);
            auto name = string(event.data[1]);
            RegisterUid(uid, name);
            _UpdateCount++;
            // trace("Pair: " + uid + " - " + name);
        } else if (ty == "Clear") {
            ClearKnownUids();
            _UpdateCount++;
            // trace("ClearKnownUids");
        } else if (ty == "IsReqActive") {
            bool inProg = event.data.Length > 0 && string(event.data[0]).ToLower() == "true";
            if (_MapList_IsInProgress != inProg) {
                if (!inProg) {
                    lastCheckEnd = Time::Now;
                }
                _UpdateCount++;
            }
            _MapList_IsInProgress = inProg;
            // trace("IsReqActive set _MapList_IsInProgress: " + _MapList_IsInProgress);
        } else {
            warn("ListUids_MLHook: unknown event type: " + ty + " - " + event.type);
        }
    }

    protected void RegisterUid(const string &in uid, const string &in name) {
        if (_MapList_MapUids.Find(uid) != -1) {
            warn("ListUids_MLHook: uid already registered: " + uid + " - " + name);
            return;
        }
        _MapList_MapUids.InsertLast(uid);
        _MapList_Names.InsertLast(name);
    }

    protected void ClearKnownUids() {
        _MapList_MapUids.RemoveRange(0, _MapList_MapUids.Length);
        _MapList_Names.RemoveRange(0, _MapList_Names.Length);
    }

    // MLFeed::MapListUids_Receiver methods

    void MapList_Request() override {
        if (_MapList_IsInProgress) {
            warn("MapList_Request: already in progress");
            return;
        }
        SendListRequestToML();
        _MapList_IsInProgress = true;
        lastCheckStart = Time::Now;
    }

    bool get_MapList_IsInProgress() const override {
        return _MapList_IsInProgress;
    }

    const array<string>@ get_MapList_Names() const override {
        return _MapList_Names;
    }

    const array<string>@ get_MapList_MapUids() const override {
        return _MapList_MapUids;
    }

    uint get_UpdateCount() const override {
        return _UpdateCount;
    }

    uint64 get_MsSinceLastReqStart() const override {
        return Time::Now - lastCheckStart;
    }

    uint64 get_MsSinceLastReqEnd() const override {
        return Time::Now - lastCheckEnd;
    }

    uint64 get_LastRequestStart() const override {
        return lastCheckStart;
    }

    uint64 get_LastRequestEnd() const override {
        return lastCheckEnd;
    }
}
// MLHook::Queue_MessageManialinkPlayground
