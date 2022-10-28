const string GD_PageUID = "GhostData";

// class HookGhostData : MLHook::HookMLEventsByType {
class HookGhostData : MLFeed::SharedGhostDataHook {
    private array<const MLFeed::GhostInfo@> _ghosts;
    private string lastMap;

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
        }
    }

    void OnMapChange() {
        lastMap = CurrentMap;
        _ghosts.RemoveRange(0, _ghosts.Length);
        RefreshGhostData();
    }

    void OnEvent(MLHook::PendingEvent@ event) override {
        pending.InsertLast(event);
    }

    void ProcessEvent(MLHook::PendingEvent@ event) {
        // only ghost data events, only one kind
        // send back: [Id.Value, Nickname, Result.Score, Result.Time, Result.Checkpoints]
        auto ghost = MLFeed::GhostInfo(event);
        _ghosts.InsertLast(ghost);
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
        if (UI::CollapsingHeader("" + i + ". " + ghost.Nickname)) {
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
            for (uint i = 0; i < ghost.Checkpoints.Length; i++) {
                cpTimes += (i == 0 ? "" : ", ") + ghost.Checkpoints[i];
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
