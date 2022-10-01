namespace MLFeed {
    external shared class HookKoStatsEventsBase;

    shared class KoDataProxy {
        private HookKoStatsEventsBase@ hook;
        RaceDataProxy(HookKoStatsEventsBase@ h) {
            @hook = h;
        }
        PlayerCpInfo@ GetPlayerState(const string &in name) {
            return hook.GetPlayerState(name);
        }
        string get_Map() {
            return hook.lastMap;
        }
        string get_GameMode() {
            return hook.lastGM;
        }
    }
}
