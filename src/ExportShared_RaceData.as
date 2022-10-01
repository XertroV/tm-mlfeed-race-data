namespace MLFeed {
    external shared class HookRaceStatsEventsBase;
    external shared class PlayerCpInfo;

    shared class RaceDataProxy {
        private HookRaceStatsEventsBase@ hook;
        RaceDataProxy(HookRaceStatsEventsBase@ h) {
            @hook = h;
        }
        PlayerCpInfo@ GetPlayer(const string &in name) {
            return hook.GetPlayer(name);
        }
        string get_Map() {
            return hook.lastMap;
        }
        array<PlayerCpInfo@> get_SortedPlayers_Race() {
            return hook.sortedPlayers_Race;
        }
        array<PlayerCpInfo@> get_SortedPlayers_TimeAttack() {
            return hook.sortedPlayers_TimeAttack;
        }
        uint get_CPCount() {
            return hook.CpCount;
        }
        uint get_LapCount() {
            return hook.CpCount;
        }
    }
}
