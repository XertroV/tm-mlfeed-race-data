HookRaceStatsEvents@ theHook = null;
bool g_windowVisible = false;

void Main() {
    MLHook::RequireVersionApi('0.1.5');
    startnew(InitCoro);
}

void InitCoro() {
    IO::FileSource refreshCode("RaceStatsFeed.Script.txt");
    string manialinkScript = refreshCode.ReadToEnd();
    MLHook::InjectManialinkToPlayground("RaceStatsFeed", manialinkScript, true);
    yield();
    auto hook = HookRaceStatsEvents();
    @theHook = hook;
    startnew(CoroutineFunc(hook.MainCoro));
    MLHook::RegisterMLHook(hook);
}

void RenderInterface() {
    if (!g_windowVisible) return;
    if (UI::Begin("Race Stats", g_windowVisible, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)) {
        DrawMainInterior();
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem("\\$2f8" + Icons::ListAlt + "\\$z Race Stats", "", g_windowVisible)) {
        g_windowVisible = !g_windowVisible;
    }
}

void DrawMainInterior() {
    // we assume `theHook` is non-null & other such conditions have been checked.
    // SizingFixedFit / fixedsame / strechsame / strechprop
    if (UI::BeginTable("player times", 5, UI::TableFlags::SizingStretchSame)) {
        // UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 50);
        // UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthFixed, 200);
        UI::TableSetupColumn("Player");
        UI::TableSetupColumn("CP #");
        UI::TableSetupColumn("CP Lap Time");
        UI::TableSetupColumn("Lap Time");
        UI::TableSetupColumn("Race Time");
        UI::TableHeadersRow();

        auto playerIds = theHook.latestPlayerStats.GetKeys();
        for (uint i = 0; i < playerIds.Length; i++) {
            auto player = cast<PlayerStats>(theHook.latestPlayerStats[playerIds[i]]);
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(player.Name);
            UI::TableNextColumn();
            UI::Text('' + player.CurrentLapTimes.Length);
            UI::TableNextColumn();
            if (player.CurrentLapTimes.Length > 0)
                UI::Text(Text::Format("%.3f", float(player.CurrentLapTimes[player.CurrentLapTimes.Length - 1]) / 1000.0));
            else
                UI::Text('---');
            UI::TableNextColumn();
            if (player.CurrentLapTime < 100000)
                UI::Text(Text::Format("%.3f", float(player.CurrentLapTime) / 1000.0));
            UI::TableNextColumn();
            if (player.CurrentRaceTime < 100000)
                UI::Text(Text::Format("%.3f", float(player.CurrentRaceTime) / 1000.0));
        }
        UI::EndTable();
    }
}

CTrackMania@ get_app() {
    return cast<CTrackMania>(GetApp());
}

CGameManiaAppPlayground@ get_cmap() {
    return app.Network.ClientManiaAppPlayground;
}

class HookRaceStatsEvents : MLHook::HookMLEventsByType {
    HookRaceStatsEvents() {
        super("RaceStats");
    }

    string[] incoming_msgs;
    string lastMap;
    dictionary latestPlayerStats;

    void MainCoro() {
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

    void ProcessMsg(const string &in msg) {
        auto playerStats = Json::Parse(msg);
        for (uint i = 0; i < playerStats.Length; i++) {
            auto player = PlayerStats(playerStats[i]);
            UpdatePlayer(player);
        }
    }

    void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) {
        incoming_msgs.InsertLast(data[0]);
    }

    /* main functionality logic */

    void UpdatePlayer(PlayerStats@ player) {
        // if we care about WebServicesUserId we need to add it to the accompanying maniascript
        // let's assume player names are unique b/c easier and less json
        //----
        // we need to check a player and see if their CP times have improved
        // length is an easy check
        // after that we just append
        // why not just set if we have the data already?
        @latestPlayerStats[player.Name] = player;
        // trace('Got player: ' + player.ToString());
    }

    void OnMapChange() {
        latestPlayerStats.DeleteAll();
    }

    string get_CurrentMap() const {
        auto map = GetApp().RootMap;
        if (map is null) return "";
        return map.EdChallengeId;
    }
}
