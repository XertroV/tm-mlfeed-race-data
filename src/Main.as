HookRaceStatsEvents@ theHook = null;
[Setting hidden]
bool g_windowVisible = false;

UI::Font@ subheadingFont = UI::LoadFont("DroidSans.ttf", 18, -1, -1, true, true);

enum Cmp {Lt = -1, Eq = 0, Gt = 1}

void Main() {
    MLHook::RequireVersionApi('0.1.5');
    startnew(InitCoro);
}

void InitCoro() {
    IO::FileSource refreshCode("RaceStatsFeed.Script.txt");
    string manialinkScript = "\n<script><!--\n\n" + refreshCode.ReadToEnd() + "\n\n--></script>\n";
    yield();
    auto hook = HookRaceStatsEvents();
    @theHook = hook;
    startnew(CoroutineFunc(hook.MainCoro));
    MLHook::RegisterMLHook(hook, "RaceStats");
    MLHook::RegisterMLHook(hook, "RaceStats_ActivePlayers");
    yield();
    MLHook::InjectManialinkToPlayground("RaceStatsFeed", manialinkScript, true);
}

void RenderInterface() {
    if (!g_windowVisible) return;
    UI::PushFont(subheadingFont);
    if (UI::Begin("Race Stats", g_windowVisible, UI::WindowFlags::NoCollapse)) { // UI::WindowFlags::AlwaysAutoResize |
        DrawMainInterior();
    }
    UI::End();
    UI::PopFont();
}

void RenderMenu() {
    if (UI::MenuItem("\\$2f8" + Icons::ListAlt + "\\$z Race Stats", "", g_windowVisible)) {
        g_windowVisible = !g_windowVisible;
    }
}

void DrawMainInterior() {
    if (theHook is null) return;
    if (theHook.latestPlayerStats is null) return;
    if (theHook.sortedPlayers.Length == 0) return;
    // we assume `theHook` is non-null & other such conditions have been checked.
    // SizingFixedFit / fixedsame / strechsame / strechprop
    if (UI::BeginTable("player times", 4, UI::TableFlags::SizingStretchProp)) {
        // UI::TableSetupColumn("Time", UI::TableColumnFlags::WidthFixed, 50);
        // UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthFixed, 200);
        UI::TableSetupColumn("Player");
        UI::TableSetupColumn("CP #");
        UI::TableSetupColumn("CP Lap Time");
        UI::TableSetupColumn("Best Time");
        // UI::TableSetupColumn("Lap Time");
        // UI::TableSetupColumn("Race Time");
        UI::TableHeadersRow();

        // auto playerIds = theHook.latestPlayerStats.GetKeys();
        // theHook.latestPlayerStats.GetValues();
        for (uint i = 0; i < theHook.sortedPlayers.Length; i++) {
            auto player = cast<PlayerCpInfo>(theHook.sortedPlayers[i]);
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(player.name);
            UI::TableNextColumn();
            UI::Text('' + player.cpCount);
            UI::TableNextColumn();
            if (player.cpCount > 0) {
                UI::Text(MsToSeconds(player.lastCpTime));
            } else {
                UI::Text('---');
            }
            UI::TableNextColumn();
            auto bt = int(theHook.bestTimes[player.name]);
            if (bt > 0) {
                UI::Text(MsToSeconds(bt));
            }
            // if (player.CurrentLapTimes.Length > 0)
            //     UI::Text(Text::Format("%.3f", float(player.CurrentLapTimes[player.CurrentLapTimes.Length - 1]) / 1000.0));
            // else
            //     UI::Text('---');
            // UI::TableNextColumn();
            // if (player.CurrentLapTime < 100000)
            //     UI::Text(Text::Format("%.3f", float(player.CurrentLapTime) / 1000.0));
            // UI::TableNextColumn();
            // if (player.CurrentRaceTime < 100000)
            //     UI::Text(Text::Format("%.3f", float(player.CurrentRaceTime) / 1000.0));
        }
        UI::EndTable();
    }
}

const string MsToSeconds(int t) {
    return Text::Format("%.3f", float(t) / 1000.0);
}

CTrackMania@ get_app() {
    return cast<CTrackMania>(GetApp());
}

CGameManiaAppPlayground@ get_cmap() {
    return app.Network.ClientManiaAppPlayground;
}

Cmp cmpRace(PlayerCpInfo@ p1, PlayerCpInfo@ p2) {
    // if we have the same CPs, lowest time is better
    if (p1.cpCount == p2.cpCount)
        return cmpInt(p1.lastCpTime, p2.lastCpTime);
    // Lt => better ranking, so more CPs is better
    if (p1.cpCount > p2.cpCount) return Cmp::Lt;
    return Cmp::Gt;
}

Cmp cmpTimeAttack(PlayerCpInfo@ p1, PlayerCpInfo@ p2) {
    // start isn't synchronized
    // idea 1: sort by fastest progress
    // - a player should be above everyone given their pace at that CP
    // - not based on % progression
    // todo: probably need a different data structure
    return Cmp::Eq;
}

Cmp cmpInt(int a, int b) {
    if (a < b) return Cmp::Lt;
    if (a == b) return Cmp::Eq;
    return Cmp::Gt;
}

class PlayerCpInfo {
    string name;
    int cpCount;
    int lastCpTime;
    PlayerCpInfo(MwFastBuffer<wstring> &in msg) {
        if (msg.Length < 3) {
            warn('PlayerCpInfo msg had insufficient length');
            return;
        }
        name = msg[0];
        cpCount = Text::ParseInt(msg[1]);
        lastCpTime = Text::ParseInt(msg[2]);
    }
    int opCmp(PlayerCpInfo@ other) {
        return int(cmpRace(this, other));
    }
}

class HookRaceStatsEvents : MLHook::HookMLEventsByType {
    HookRaceStatsEvents() {
        super("RaceStats");
    }

    MwFastBuffer<wstring>[] incoming_msgs;
    string lastMap;
    dictionary latestPlayerStats;
    dictionary bestTimes;
    array<PlayerCpInfo@> sortedPlayers;

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

    void ProcessMsg(MwFastBuffer<wstring> &in msg) {
        UpdatePlayer(PlayerCpInfo(msg));
    }

    void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override {
        if (type.EndsWith("ActivePlayers")) {
            // update active player list
            UpdateActivePlayers(data[0], data[1]);
            return;
        }
        incoming_msgs.InsertLast(data);
    }

    /* main functionality logic */

    void UpdatePlayer(PlayerCpInfo@ player) {
        @latestPlayerStats[player.name] = player;
        UpdateSortedPlayers();
    }

    void UpdateSortedPlayers() {
        sortedPlayers.RemoveRange(0, sortedPlayers.Length);
        auto ps = latestPlayerStats.GetKeys();
        for (uint i = 0; i < ps.Length; i++) {
            auto player = cast<PlayerCpInfo>(latestPlayerStats[ps[i]]);
            sortedPlayers.InsertLast(player);
        }
        sortedPlayers.SortAsc();
    }

    void UpdateActivePlayers(const string &in playersCsv, const string &in bestTimesCsv) {
        auto players = playersCsv.Split(",");
        auto newBestTimes = bestTimesCsv.Split(",");
        bestTimes.DeleteAll();
        for (uint i = 0; i < players.Length; i++) {
            auto bt = Text::ParseInt(newBestTimes[i]);
            bestTimes[players[i]] = bt;
        }
        auto prevPlayers = latestPlayerStats.GetKeys();
        for (uint i = 0; i < prevPlayers.Length; i++) {
            auto p = prevPlayers[i];
            if (!bestTimes.Exists(p)) {
                latestPlayerStats.Delete(p);
            }
        }
    }

    void OnMapChange() {
        latestPlayerStats.DeleteAll();
        sortedPlayers.RemoveRange(0, sortedPlayers.Length);
    }

    string get_CurrentMap() const {
        auto map = GetApp().RootMap;
        if (map is null) return "";
        return map.EdChallengeId;
    }
}
