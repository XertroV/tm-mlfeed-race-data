const string NOTE_OPTIONAL = "\\$bbb (Optional component)\\$z";

namespace RaceFeedUI {
    bool g_windowVisible = false;

    array<Tab@> tabs;

    void Render() {
        if (!g_windowVisible) return;
        if (theHook is null) return;

        if (tabs.Length == 0) {
            tabs.InsertLast(MainTab());
            tabs.InsertLast(RaceTab());
            tabs.InsertLast(RaceRespawnsTab());
            tabs.InsertLast(TaTab());
            tabs.InsertLast(BestTimesTab());
            tabs.InsertLast(CPTimes());
            tabs.InsertLast(RespawnsTab());
            tabs.InsertLast(RespawnsTimesTab());
        }

        if (UI::Begin("Race Feed Demo UI", g_windowVisible)) {
            UI::BeginTabBar("race data tab bar");
            for (uint i = 0; i < tabs.Length; i++) {
                tabs[i].DrawTab();
                // we can get an index OOB if the last tab is removed
                if (i < tabs.Length) tabs[i].DrawWindow();
            }
            UI::EndTabBar();
        }
        UI::End();
    }

    void RenderMenu() {
        if (UI::MenuItem(Icons::Rss + " Race Feed Demo", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }

    class MainTab : Tab {
        MainTab() {
            super("Global Race Data");
        }

        void DrawInner() override {
            // UI::Text("latestPlayerStats.GetSize(): " + theHook.latestPlayerStats.GetSize());
            UI::Text("NbPlayers: " + theHook.SortedPlayers_Race.Length);
            UI::Text("SpawnCounter: " + theHook.SpawnCounter);
            UI::Text("Map: " + theHook.lastMap);
            UI::Text("Map CpCount: " + theHook.CpCount);
            UI::Text("Map LapCount: " + theHook.LapCount);
            UI::Text("Map CPsToFinish: " + theHook.CPsToFinish);
            UI::Dummy(vec2(0, 20));
            int lrt = recordHook is null ? -1 : recordHook.LastRecordTime;
            UI::Text("LastRecordTime: " + lrt); // + NOTE_OPTIONAL);
        }
    }

    class RaceTab : Tab {
        RaceTab() {
            super("Players (" + mode + ")");
        }

        const string get_mode() { return "Race"; }

        array<MLFeed::PlayerCpInfo_V2@> get_Players() {
            return theHook.SortedPlayers_Race;
        }

        uint PlayersRank(MLFeed::PlayerCpInfo_V2@ player) {
            return player.RaceRank;
        }

        void DrawInner() override {
            auto @players = Players;
            UI::Text("Players ("+players.Length+") sorted for: " + mode + ". " + theHook.CPsToFinish + " total CPs incl finish.");
            uint nCols = 11;
            if (UI::BeginTable("players debug " + mode, nCols, UI::TableFlags::SizingStretchProp)) {

                UI::TableSetupColumn("Rank");
                UI::TableSetupColumn("Name");
                UI::TableSetupColumn("StartTime");
                UI::TableSetupColumn("CurrentRaceTime");
                UI::TableSetupColumn("CpCount");
                UI::TableSetupColumn("LastCpTime");
                UI::TableSetupColumn("BestTime");
                UI::TableSetupColumn("SpawnStatus");
                UI::TableSetupColumn("Local?");
                UI::TableSetupColumn("Lag Est");

                UI::TableSetupColumn(""); // view player's tab

                UI::TableHeadersRow();

                UI::ListClipper clipper(players.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto ps = players[i];
                        UI::TableNextRow();
                        if (ps is null) { continue; }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();
                        UI::Text(Text::Format("%2d.", PlayersRank(ps)));

                        UI::TableNextColumn();
                        UI::Text(ps.Name);

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.StartTime));

                        UI::TableNextColumn();
                        UI::Text(Time::Format(ps.CurrentRaceTime));

                        UI::TableNextColumn();
                        UI::Text('' + ps.CpCount);

                        UI::TableNextColumn();
                        UI::Text('' + ps.LastCpTime);

                        UI::TableNextColumn();
                        UI::Text('' + ps.BestTime);

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.SpawnStatus));

                        UI::TableNextColumn();
                        UI::Text(ps.IsLocalPlayer ? Icons::Check : Icons::Times);

                        UI::TableNextColumn();
                        UI::Text(Text::Format("%.1f", ps.latencyEstimate));

                        UI::TableNextColumn();
                        if (UI::Button("View##"+ps.Name)) {
                            tabs.InsertLast(PlayerTab(ps.Name));
                            tabs[tabs.Length - 1].windowOpen = true;
                        }
                    }
                }

                UI::EndTable();
            }
        }
    }

    class TaTab : RaceTab {
        TaTab() {
            super();
        }
        const string get_mode() override { return "Time Attack"; }
        array<MLFeed::PlayerCpInfo_V2@> get_Players() override {
            return theHook.SortedPlayers_TimeAttack;
        }
        uint PlayersRank(MLFeed::PlayerCpInfo_V2@ player) override {
            return player.TaRank;
        }
    }

    class RaceRespawnsTab : RaceTab {
        RaceRespawnsTab() {
            super();
        }
        const string get_mode() override { return "Race Respawns"; }
        array<MLFeed::PlayerCpInfo_V2@> get_Players() override {
            return theHook.SortedPlayers_Race_Respawns;
        }
        uint PlayersRank(MLFeed::PlayerCpInfo_V2@ player) override {
            return player.RaceRespawnRank;
        }
    }

    class CPTimes : RaceTab {
        CPTimes() {
            super();
        }

        const string get_mode() override { return "CP Times"; }

        void DrawInner() override {
            auto @players = Players;
            UI::Text("Players ("+players.Length+") CP Times.");
            uint nCols = 3 + Math::Min(theHook.CPsToFinish, 61);
            if (UI::BeginTable("players debug " + mode, nCols, UI::TableFlags::SizingStretchProp)) {

                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                for (int i = 0; i <= Math::Min(theHook.CPsToFinish, 61); i++) {
                    UI::TableSetupColumn("CP " + i);
                }

                UI::TableHeadersRow();

                UI::ListClipper clipper(players.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto ps = players[i];
                        UI::TableNextRow();
                        if (ps is null) { continue; }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();
                        UI::Text(ps.Name);

                        for (uint cp = 0; int(cp) <= Math::Min(theHook.CPsToFinish, 61); cp++) {
                            UI::TableNextColumn();
                            if (ps.CpTimes is null || ps.CpTimes.Length <= cp) continue;
                            UI::Text(Time::Format(ps.CpTimes[cp]));
                        }

                        UI::TableNextColumn();
                        if (UI::Button("View##"+ps.Name)) {
                            tabs.InsertLast(PlayerTab(ps.Name));
                            tabs[tabs.Length - 1].windowOpen = true;
                        }
                    }
                }

                UI::EndTable();
            }
        }
    }

    class BestTimesTab : TaTab {
        BestTimesTab() {
            super();
        }

        const string get_mode() override { return "Best Times"; }

        void DrawInner() override {
            auto @players = Players;
            UI::Text("Players ("+players.Length+") Best Times.");
            uint nCols = 3 + Math::Min(theHook.CPsToFinish, 61); // max 64 cols
            if (UI::BeginTable("players debug " + mode, nCols, UI::TableFlags::SizingStretchProp)) {

                UI::TableSetupColumn("Name");
                for (int i = 0; i < Math::Min(theHook.CPsToFinish, 61); i++) {
                    UI::TableSetupColumn("CP " + (i+1));
                }
                UI::TableSetupColumn("");

                UI::TableHeadersRow();

                UI::ListClipper clipper(players.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto ps = players[i];
                        UI::TableNextRow();
                        if (ps is null) { continue; }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();
                        UI::Text(ps.Name);

                        for (uint cp = 0; int(cp) <= Math::Min(theHook.CPsToFinish, 61); cp++) {
                            UI::TableNextColumn();
                            if (ps.BestRaceTimes is null || ps.BestRaceTimes.Length <= cp) continue;
                            UI::Text(Time::Format(ps.BestRaceTimes[cp]));
                        }

                        UI::TableNextColumn();
                        if (UI::Button("View##"+ps.Name)) {
                            tabs.InsertLast(PlayerTab(ps.Name));
                            tabs[tabs.Length - 1].windowOpen = true;
                        }
                    }
                }

                UI::EndTable();
            }
        }
    }

    class RespawnsTab : TaTab {
        RespawnsTab() {
            super();
        }

        const string get_mode() override { return "Respawns Info"; }


        void DrawInner() override {
            auto @players = Players;
            UI::Text("Players ("+players.Length+") Respawns Info.");
            uint nCols = 8;
            if (UI::BeginTable("players debug " + mode, nCols, UI::TableFlags::SizingStretchProp)) {

                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Spawned");
                UI::TableSetupColumn("Nb");
                UI::TableSetupColumn("Last Cp/Respawn Time");
                UI::TableSetupColumn("Last Respawn");
                UI::TableSetupColumn("Last Respawn CP");
                UI::TableSetupColumn("Time Lost");
                UI::TableSetupColumn("");

                UI::TableHeadersRow();

                UI::ListClipper clipper(players.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto ps = players[i];
                        UI::TableNextRow();
                        if (ps is null) { continue; }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();
                        UI::Text(ps.Name);

                        UI::TableNextColumn();
                        UI::Text(ps.IsSpawned ? Icons::Check : Icons::Times);

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.NbRespawnsRequested));

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.LastCpOrRespawnTime));

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.LastRespawnRaceTime));

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.LastRespawnCheckpoint));

                        UI::TableNextColumn();
                        UI::Text(tostring(ps.TimeLostToRespawns));

                        UI::TableNextColumn();
                        if (UI::Button("View##"+ps.Name)) {
                            tabs.InsertLast(PlayerTab(ps.Name));
                            tabs[tabs.Length - 1].windowOpen = true;
                        }
                    }
                }

                UI::EndTable();
            }
        }
    }

    class RespawnsTimesTab : TaTab {
        RespawnsTimesTab() {
            super();
        }

        const string get_mode() override { return "Time Loss by CP"; }

        void DrawInner() override {
            auto @players = Players;
            UI::Text("Players ("+players.Length+") Time Loss by CP.");
            uint nCols = 3 + Math::Min(theHook.CPsToFinish, 61);
            if (UI::BeginTable("players debug " + mode, nCols, UI::TableFlags::SizingStretchProp)) {

                UI::TableSetupColumn("Name");
                for (int i = 0; i <= Math::Min(theHook.CPsToFinish, 61); i++) {
                    UI::TableSetupColumn("CP " + i);
                }

                UI::TableSetupColumn("");
                UI::TableHeadersRow();

                UI::ListClipper clipper(players.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        auto ps = players[i];
                        UI::TableNextRow();
                        if (ps is null) { continue; }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();
                        UI::Text(ps.Name);

                        for (uint cp = 0; int(cp) <= Math::Min(theHook.CPsToFinish, 61); cp++) {
                            UI::TableNextColumn();
                            if (ps.TimeLostToRespawnByCp is null || ps.TimeLostToRespawnByCp.Length <= cp) continue;
                            UI::Text(tostring(ps.TimeLostToRespawnByCp[cp]));
                        }

                        UI::TableNextColumn();
                        if (UI::Button("View##"+ps.Name)) {
                            tabs.InsertLast(PlayerTab(ps.Name));
                            tabs[tabs.Length - 1].windowOpen = true;
                        }
                    }
                }

                UI::EndTable();
            }
        }
    }

    class PlayerTab : Tab {
        string name;
        PlayerTab(const string &in name) {
            this.name = name;
            super("P: " + name);
        }

        int get_TabFlags() override {
            return UI::TabItemFlags::NoReorder
                ;
        }

        void DrawInner() override {
            UI::Text("Player Stats: " + name);
            auto player = theHook.GetPlayer_V2(name);

            if (player is null) {
                UI::Text("Player not found :(");
                return;
            }
            if (UI::BeginTable("player-stats##"+name, 2, UI::TableFlags::SizingFixedSame)) {
                DrawPair("Latency Est. (ms): ", tostring(player.latencyEstimate));

                DrawPair("CpCount: ", tostring(player.CpCount));
                DrawPair("LastRespawnCheckpoint: ", tostring(player.LastRespawnCheckpoint));

                DrawPair("LastCpTime: ", tostring(player.LastCpTime));
                DrawPair("LastRespawnTime: ", tostring(player.LastRespawnRaceTime));
                DrawPair("LastCpOrRespawnTime: ", tostring(player.LastCpOrRespawnTime));

                DrawPair("NbRespawnsRequested: ", tostring(player.NbRespawnsRequested));
                DrawPair("TimeLostToRespawns: ", tostring(player.TimeLostToRespawns));
                DrawPair("LastTheoreticalCpTime: ", tostring(player.LastTheoreticalCpTime));

                DrawPair("CurrentRaceTime: ", tostring(player.CurrentRaceTime));
                DrawPair("CurrentRaceTimeRaw: ", tostring(player.CurrentRaceTimeRaw));
                DrawPair("TheoreticalRaceTime: ", tostring(player.TheoreticalRaceTime));

                UI::EndTable();
            }
        }

        void DrawPair(const string &in l, const string &in r) {
            UI::TableNextColumn();
            UI::Text(l);
            UI::TableNextColumn();
            UI::Text(r);
        }
    }


    class Tab {
        // bool canCloseTab = false;

        bool tabOpen = true;
        bool windowOpen {
            get { return !tabOpen; }
            set { tabOpen = !value; }
        }

        string tabName;

        Tab(const string &in tabName) {
            this.tabName = tabName;
        }

        int get_TabFlags() {
            return UI::TabItemFlags::NoCloseWithMiddleMouseButton
                | UI::TabItemFlags::NoReorder
                ;
        }

        int get_WindowFlags() {
            return UI::WindowFlags::AlwaysAutoResize
                | UI::WindowFlags::NoCollapse
                ;
        }

        void DrawTogglePop() {
            if (UI::Button((tabOpen ? "Pop Out" : "Back to Tab") + "##" + tabName)) {
                tabOpen = !tabOpen;
            }
            UI::SameLine();
            UI::SetCursorPos(UI::GetCursorPos() + vec2(20, 0));
            if (UI::Button("Remove##"+tabName)) {
                tabs.RemoveAt(tabs.FindByRef(this));
            }
        }

        void DrawTab() {
            if (!tabOpen) return;
            if (UI::BeginTabItem(tabName, TabFlags)) {
                DrawTogglePop();
                DrawInner();
                UI::EndTabItem();
            }
        }

        void DrawInner() {
            UI::Text("Tab Inner: " + tabName);
            UI::Text("Overload `DrawInner()`");
        }

        void DrawWindow() {
            if (!windowOpen) return;
            if (UI::Begin(tabName, windowOpen, WindowFlags)) {
                DrawTogglePop();
                DrawInner();
            }
            UI::End();
        }
    }


}
