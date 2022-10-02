namespace RaceFeedUI {
    bool g_windowVisible = false;

    void Render() {
        if (!g_windowVisible) return;
        if (theHook is null) return;

        if (UI::Begin("Race Feed Demo UI", g_windowVisible)) {
            // if (UI::Button("Update Player States")) {
            //     koFeedHook.AskForAllPlayerStates();
            // }
            UI::Text("Last Map: " + theHook.lastMap);
            UI::Text("latestPlayerStats.GetSize(): " + theHook.latestPlayerStats.GetSize());
            UI::Text("CpCount: " + theHook.CpCount);
            UI::Text("LapCount: " + theHook.LapCount);
            UI::Text("CPsToFinish: " + theHook.CPsToFinish);
            UI::Text("SpawnCounter: " + theHook.SpawnCounter);
            UI::Dummy(vec2(0, 20));
            UI::Text("Players sorted as in a Race");
            UI::Separator();
            auto @sorted = theHook.sortedPlayers_Race;
            UI::ListClipper clipper(sorted.Length);
            while (clipper.Step()) {
                for (uint i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    auto ps = sorted[i];
                    if (ps is null) { continue; }
                    UI::Text(ps.ToString());
                }
            }

            UI::Dummy(vec2(0, 20));
            UI::Text("Players sorted by best time");
            UI::Separator();
            @sorted = theHook.sortedPlayers_TimeAttack;
            UI::ListClipper clipperTA(sorted.Length);
            while (clipperTA.Step()) {
                for (uint i = clipperTA.DisplayStart; i < clipperTA.DisplayEnd; i++) {
                    auto ps = sorted[i];
                    if (ps is null) { continue; }
                    UI::Text(ps.ToString());
                }
            }

            UI::End();
        }
    }

    void RenderMenu() {
        if (UI::MenuItem(Icons::Rss + " Race Feed Demo", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }
}
