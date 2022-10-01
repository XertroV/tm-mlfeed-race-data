namespace KoFeedUI {
    bool g_windowVisible = false;

    void Render() {
        if (!g_windowVisible) return;
        if (koFeedHook is null) return;

        if (UI::Begin("KO Feed Demo UI", g_windowVisible)) {
            if (UI::Button("Update Player States")) {
                koFeedHook.AskForAllPlayerStates();
            }
            UI::Text("Game Mode: " + koFeedHook.lastGM);
            UI::Text("Division: " + koFeedHook.division);
            UI::Text("mapRoundNb: " + koFeedHook.mapRoundNb);
            UI::Text("mapRoundTotal: " + koFeedHook.mapRoundTotal);
            UI::Text("roundNb: " + koFeedHook.roundNb);
            UI::Text("roundTotal: " + koFeedHook.roundTotal);
            UI::Text("playersNb: " + koFeedHook.playersNb);
            UI::Text("kosMilestone: " + koFeedHook.kosMilestone);
            UI::Text("kosNumber: " + koFeedHook.kosNumber);
            UI::Separator();
            for (uint i = 0; i < koFeedHook.players.Length; i++) {
                auto ps = koFeedHook.GetPlayerState(koFeedHook.players[i]);
                if (ps is null) {
                    warn('got null player state for ' + koFeedHook.players[i]);
                    continue;
                }
                UI::Text(ps.name + " -- " + (ps.isAlive ? "Alive" : "KO") + (ps.isDNF ? "; DNF" : ""));
            }
            UI::End();
        }
    }

    void RenderMenu() {
        if (UI::MenuItem(Icons::Rss + " KO Feed Demo", "", g_windowVisible)) {
            g_windowVisible = !g_windowVisible;
        }
    }
}
