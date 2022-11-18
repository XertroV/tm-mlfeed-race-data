const string NOTE_OPTIONAL = "\\$bbb (Optional component)\\$z";

namespace RaceFeedUI {
    bool g_windowVisible = false;

    void Render() {
        if (!g_windowVisible) return;
        if (theHook is null) return;

        if (UI::Begin("Race Feed Demo UI", g_windowVisible)) {
            UI::Text("Last Map: " + theHook.lastMap);
            UI::Text("latestPlayerStats.GetSize(): " + theHook.latestPlayerStats.GetSize());
            UI::Text("CpCount: " + theHook.CpCount);
            UI::Text("LapCount: " + theHook.LapCount);
            UI::Text("CPsToFinish: " + theHook.CPsToFinish);
            UI::Text("SpawnCounter: " + theHook.SpawnCounter);
            UI::Dummy(vec2(0, 20));
            int lrt = recordHook is null ? -1 : recordHook.LastRecordTime;
            UI::Text("LastRecordTime: " + lrt); // + NOTE_OPTIONAL);
            UI::Dummy(vec2(0, 20));
            UI::Text("Players sorted as in a Race");
            UI::Separator();
            auto @sorted = theHook.sortedPlayers_Race;
            UI::ListClipper clipper(sorted.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    auto ps = sorted[i];
                    if (ps is null) { continue; }
                    UI::Text("" + ps.raceRank + ". " + ps.ToString());
                }
            }

            UI::Dummy(vec2(0, 20));
            UI::Text("Players sorted by best time");
            UI::Separator();
            @sorted = theHook.sortedPlayers_TimeAttack;
            UI::ListClipper clipperTA(sorted.Length);
            while (clipperTA.Step()) {
                for (int i = clipperTA.DisplayStart; i < clipperTA.DisplayEnd; i++) {
                    auto ps = sorted[i];
                    if (ps is null) { continue; }
                    UI::Text("" + ps.taRank + ". " + ps.ToString());
                }
            }

            UI::Dummy(vec2(0, 20));
            UI::Text("Players best cp times:");
            UI::Separator();
            @sorted = theHook.sortedPlayers_TimeAttack;
            UI::ListClipper clipperTA2(sorted.Length);
            while (clipperTA2.Step()) {
                for (int i = clipperTA2.DisplayStart; i < clipperTA2.DisplayEnd; i++) {
                    auto ps = sorted[i];
                    if (ps is null) { continue; }
                    auto @times = MLFeed::GetPlayersBestTimes(ps.name);
                    string ts = "";
                    if (times !is null) {
                        // if (times is null) continue;
                        for (uint j = 0; j < times.Length; j++) {
                            ts += tostring(times[j]);
                            if (j < times.Length - 1) ts += ", ";
                        }
                    }
                    UI::Text("" + ps.taRank + ". " + ts);
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
