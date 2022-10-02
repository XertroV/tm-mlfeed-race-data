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
            UI::Separator();
            for (uint i = 0; i < theHook.sortedPlayers_Race.Length; i++) {
                auto ps = theHook.sortedPlayers_Race[i];
                if (ps is null) { continue; }
                UI::Text(ps.ToString());
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
