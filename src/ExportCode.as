namespace MLFeed {
    const RaceDataProxy@ GetRaceData() {
        auto plugin = Meta::ExecutingPlugin();
        RaceDataProxy@ ret;
        if (!pluginToRaceData.Get(plugin.ID, @ret)) {
            @ret = RaceDataProxy(theHook, recordHook);
            @pluginToRaceData[plugin.ID] = ret;
        }
        return ret;
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

    const SharedGhostDataHook@ GetGhostData() {
        return ghostHook;
    }
}
