namespace MLFeed {
    const RaceDataProxy@ GetRaceData() {
        auto plugin = Meta::ExecutingPlugin();
        RaceDataProxy@ ret;
        while (theHook is null) yield();
        if (!pluginToRaceData.Get(plugin.ID, @ret)) {
            @ret = RaceDataProxy(theHook, recordHook);
            @pluginToRaceData[plugin.ID] = ret;
        }
        return ret;
    }

    const HookRaceStatsEventsBase_V2@ GetRaceData_V2() {
        return theHook;
    };

    const array<uint>@ GetPlayersBestTimes(const string &in playerName) {
        return theHook.GetPlayersBestTimes(playerName);
    }

    const KoDataProxy@ GetKoData() {
        auto plugin = Meta::ExecutingPlugin();
        KoDataProxy@ ret;
        if (!pluginToKoData.Get(plugin.ID, @ret)) {
            @ret = KoDataProxy(koFeedHook);
            @pluginToKoData[plugin.ID] = ret;
        }
        return ret;
    }

    const SharedGhostDataHook_V2@ GetGhostData() {
        return ghostHook;
    }
}
