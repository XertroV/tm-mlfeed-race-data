const string GD_PageUID = "GhostData";

// class HookGhostData : MLHook::HookMLEventsByType {
class HookGhostData : MLFeed::SharedGhostDataHook_V2 {
    private array<MwId> ignoreGhosts;
    private array<const MLFeed::GhostInfo_V2@> _ghosts;
    private array<const MLFeed::GhostInfo@> _ghosts_copy;
    private string lastMap;
    private dictionary seenGhosts;

    HookGhostData() {
        super(GD_PageUID);
        startnew(CoroutineFunc(this.MainCoro));
        RefreshGhostData();
        lastMap = CurrentMap;
    }

    void RefreshGhostData() {
        MLHook::Queue_MessageManialinkPlayground(GD_PageUID, {"RefreshGhostData"});
    }

    MLHook::PendingEvent@[] pending;

    uint last_PGS_DFM_NbGhosts = 0;

    void MainCoro() {
        while(true) {
            yield();
            if (lastMap != CurrentMap) {
                OnMapChange();
            }
            if (pending.Length > 0) {
                for (uint i = 0; i < pending.Length; i++) {
                    ProcessEvent(pending[i]);
                }
                pending.RemoveRange(0, pending.Length);
            }
            // The following does not work b/c `ghost.Result.Checkpoints` is an UnknownType in AngelScript (note: it is a c++ array as per Nadeo ManiaLink docs)
            // todo: maybe you can force cast it via pointer to an `array<int>` (or uint)
            /*
            auto pgs = GetApp().PlaygroundScript;
            if (pgs !is null) {
                if (last_PGS_DFM_NbGhosts != pgs.DataFileMgr.Ghosts.Length) {
                    last_PGS_DFM_NbGhosts = pgs.DataFileMgr.Ghosts.Length;
                    string key;
                    for (uint i = 0; i < pgs.DataFileMgr.Ghosts.Length; i++) {
                        auto item = pgs.DataFileMgr.Ghosts[i];
                        key = string(item.Nickname) + item.Result.Time;
                        if (!seenGhosts.Exists(key)) {
                            seenGhosts[key] = true;
                            string cpTimes = "";
                            for (uint i = 0; i < item.Result.Checkpoints.Length; i++) {
                                cpTimes += tostring(item.Result.Checkpoints[i]);
                                if (i < item.Result.Checkpoints.Length - 1)
                                    cpTimes += ",";
                            }
                            _ghosts.InsertLast(MLFeed::GhostInfo(MLHook::PendingEvent("", {item.IdName, item.Nickname, tostring(item.Result.Score), tostring(item.Result.Time), cpTimes})));
                        }
                    }
                }
            } */
        }
    }

    void OnMapChange(bool askForRefresh = true) {
        lastMap = CurrentMap;
        _ghosts.RemoveRange(0, _ghosts.Length);
        _ghosts_copy.RemoveRange(0, _ghosts_copy.Length);
        for (uint i = 0; i < LoadedGhosts.Length; i++) {
            LoadedGhosts[i].IsLoaded = false;
        }
        LoadedGhosts.RemoveRange(0, LoadedGhosts.Length);
        SortedGhosts.RemoveRange(0, SortedGhosts.Length);
        last_PGS_DFM_NbGhosts = 0;
        // don't delete seenGhosts so that when we change map we don't re-include old ghosts -- hopefully fixes rare bug on servers where old ghosts are counted for current map
        // seenGhosts.DeleteAll();
        if (askForRefresh)
            RefreshGhostData();
    }

    void OnEvent(MLHook::PendingEvent@ event) override {
        pending.InsertLast(event);
    }

    void ProcessEvent(MLHook::PendingEvent@ event) {
        // only ghost data events, only one type
        // if it has fewer then 5 elements then it's a special message
        if (event.data.Length < 5) {
            if (event.type.EndsWith("_Removed")) {
                RemoveByIdStr(event.data[0]);
            }
            // if (event.data.Length == 0) {
            //     warn("HookGhostData got an empty message.");
            // } else {
            //     if (event.data[0] == "RESET") {
            //         OnMapChange(false);
            //     }
            // }
            return;
        }
        // send back: [Id.Value, Nickname, Result.Score, Result.Time, Result.Checkpoints]
        string key = string(event.data[0]) + event.data[3];
        if (seenGhosts.Exists(key)) return;
        seenGhosts[key] = true;
        string nn = event.data[1];
        if (nn.EndsWith("Personal best")) {
            event.data[1] = wstring("Personal best");
        }
        auto g = MLFeed::GhostInfo_V2(event);
        _ghosts.InsertLast(g);
        _ghosts_copy.InsertLast(cast<MLFeed::GhostInfo>(g));
        AddLoadedGhost(g);
    }

    void RemoveByIdStr(const string &in ghostId) {
        for (uint i = 0; i < LoadedGhosts.Length; i++) {
            auto g = LoadedGhosts[i];
            if (g.IdName == ghostId) {
                g.IsLoaded = false;
                LoadedGhosts.RemoveAt(i);
                i--;
            }
        }
    }

    void AddLoadedGhost(MLFeed::GhostInfo_V2@ g) {
        auto initLoaded = NbLoadedGhosts;
        for (uint i = 0; i < LoadedGhosts.Length; i++) {
            auto item = LoadedGhosts[i];
            if (g.Result_Time < item.Result_Time) {
                LoadedGhosts.InsertAt(i, g);
                break;
            }
        }
        if (initLoaded == NbLoadedGhosts) {
            LoadedGhosts.InsertLast(g);
        }

        auto initGhosts = SortedGhosts.Length;
        for (uint i = 0; i < SortedGhosts.Length; i++) {
            auto item = SortedGhosts[i];
            if (g.Result_Time < item.Result_Time) {
                SortedGhosts.InsertAt(i, g);
                break;
            }
        }
        if (initGhosts == SortedGhosts.Length) {
            SortedGhosts.InsertLast(g);
        }
    }

    uint get_NbGhosts() const override {
        return _ghosts.Length;
    }

    const array<const MLFeed::GhostInfo@> get_Ghosts() const override {
        return _ghosts_copy;
    }

    const array<const MLFeed::GhostInfo_V2@> get_Ghosts_V2() const override {
        return _ghosts;
    }
}

bool g_ShowOnlyLoaded = false;
bool g_SortedGhosts = false;

namespace GhostDataUI {
    bool g_windowVisible = false;

    void Render() {
        if (!g_windowVisible) return;
        const MLFeed::SharedGhostDataHook_V2@ ghostData = MLFeed::GetGhostData();

        if (UI::Begin("Ghost Data Demo UI", g_windowVisible)) {
            if (ghostData is null) {
                UI::Text("GhostData is null.");
            } else {
                UI::Text("NbGhosts: " + ghostData.NbGhosts);
                UI::SameLine();
                UI::Text("/   NbLoadedGhosts: " + ghostData.NbLoadedGhosts);
                g_ShowOnlyLoaded = UI::Checkbox("Show only Loaded Ghosts", g_ShowOnlyLoaded);
                AddSimpleTooltip("'Loaded' ghosts should be currently accessible via DataFileMgr (under Network.ClientManiaAppPlayground).");
                if (!g_ShowOnlyLoaded) {
                    g_SortedGhosts = UI::Checkbox("Use SortedGhosts (fastest to slowest)", g_SortedGhosts);
                    AddSimpleTooltip("via `.SortedGhosts`");
                }
                UI::Separator();
                if (g_ShowOnlyLoaded) {
                    DrawGhosts_Loaded(ghostData);
                } else {
                    if (g_SortedGhosts)
                        DrawGhosts_Sorted(ghostData);
                    else
                        DrawGhosts_All(ghostData);
                }
            }
            UI::End();
        }
    }

    void DrawGhosts_All(const MLFeed::SharedGhostDataHook_V2@ ghostData) {
        for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
            auto ghost = ghostData.Ghosts_V2[i];
            DrawGhost(i, ghost);
        }
    }
    void DrawGhosts_Sorted(const MLFeed::SharedGhostDataHook_V2@ ghostData) {
        for (uint i = 0; i < ghostData.SortedGhosts.Length; i++) {
            auto ghost = ghostData.SortedGhosts[i];
            DrawGhost(i, ghost);
        }
    }
    void DrawGhosts_Loaded(const MLFeed::SharedGhostDataHook_V2@ ghostData) {
        for (uint i = 0; i < ghostData.LoadedGhosts.Length; i++) {
            auto ghost = ghostData.LoadedGhosts[i];
            DrawGhost(i, ghost);
        }
    }

    void DrawGhost(uint i, const MLFeed::GhostInfo_V2@ ghost) {
        if (UI::CollapsingHeader("" + i + ". " + ghost.Nickname + " (" + ghost.IdName + ")")) {
            UI::Text("IdName: " + ghost.IdName);
            AddSimpleTooltip("Equivalent to Ghost.IdName");
            UI::Text("IdUint: " + ghost.IdUint + " (0x" + Text::Format("%x", ghost.IdUint) + ")");
            AddSimpleTooltip("Equivalent to Ghost.Id.Value (experimental)");
            UI::Text("IsLoaded: " + tostring(ghost.IsLoaded));
            AddSimpleTooltip("True when the ghost is available via the DataFileMgr");
            UI::Text("Nickname: " + ghost.Nickname);
            AddSimpleTooltip("Equivalent to Ghost.Nickname");
            UI::Text("IsPersonalBest: " + tostring(ghost.IsPersonalBest));
            AddSimpleTooltip("True when the name is 'Personal best'");
            UI::Text("IsLocalPlayer: " + tostring(ghost.IsLocalPlayer));
            AddSimpleTooltip("True when the nickname is the same as the local player or this ghost is called 'Personal best'");
            UI::Text("Result_Score: " + ghost.Result_Score);
            AddSimpleTooltip("Equivalent to Ghost.Result.Score (note: often 0, mb always)");
            UI::Text("Result_Time: " + ghost.Result_Time);
            AddSimpleTooltip("Equivalent to Ghost.Result.Time");
            UI::Text("Checkpoints.Length: " + ghost.Checkpoints.Length);
            AddSimpleTooltip("Equivalent to Ghost.Result.Checkpoints.Length");
            string cpTimes = "";
            for (uint j = 0; j < ghost.Checkpoints.Length; j++) {
                cpTimes += (j == 0 ? "" : ", ") + ghost.Checkpoints[j];
            }
            UI::Text("Checkpoints: " + cpTimes);
            AddSimpleTooltip("Equivalent to Ghost.Result.Checkpoints");
        }
    }

    void RenderMenu() {
        if (UI::MenuItem(Icons::Rss + " Ghost Data Demo", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }
}
