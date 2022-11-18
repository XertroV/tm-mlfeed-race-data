const string GD_PageUID = "GhostData";

// class HookGhostData : MLHook::HookMLEventsByType {
class HookGhostData : MLFeed::SharedGhostDataHook {
    private array<const MLFeed::GhostInfo@> _ghosts;
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
        last_PGS_DFM_NbGhosts = 0;
        seenGhosts.DeleteAll();
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
            event.data[1] = wstring(ColoredString(event.data[1]));
        }
        auto g = MLFeed::GhostInfo(event);
        _ghosts.InsertLast(g);
    }

    uint get_NbGhosts() const override {
        return _ghosts.Length;
    }

    const array<const MLFeed::GhostInfo@> get_Ghosts() const override {
        return _ghosts;
    }
}

namespace GhostDataUI {
    bool g_windowVisible = false;

    void Render() {
        if (!g_windowVisible) return;
        const MLFeed::SharedGhostDataHook@ ghostData = MLFeed::GetGhostData();

        if (UI::Begin("Ghost Data Demo UI", g_windowVisible)) {
            if (ghostData is null) {
                UI::Text("GhostData is null.");
            } else {
                UI::Text("NbGhosts: " + ghostData.NbGhosts);
                UI::Separator();
                for (uint i = 0; i < ghostData.Ghosts.Length; i++) {
                    auto ghost = ghostData.Ghosts[i];
                    DrawGhost(i, ghost);
                }
            }
            UI::End();
        }
    }

    void DrawGhost(uint i, const MLFeed::GhostInfo@ ghost) {
        if (UI::CollapsingHeader("" + i + ". " + ghost.Nickname + " (" + ghost.IdName + ")")) {
            UI::Text("IdName: " + ghost.IdName);
            AddSimpleTooltip("Equivalent to Ghost.IdName");
            UI::Text("IdUint: " + ghost.IdUint + " (0x" + Text::Format("%x", ghost.IdUint) + ")");
            AddSimpleTooltip("Equivalent to Ghost.Id.Value (experimental)");
            UI::Text("Nickname: " + ghost.Nickname);
            AddSimpleTooltip("Equivalent to Ghost.Nickname");
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
