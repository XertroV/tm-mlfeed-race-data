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

    const SharedGhostDataHook@ GetGhostData() {
        return ghostHook;
    }

    // returns the name of the local player, or an empty string if this is not yet known
    const string get_LocalPlayersName() {
        try {
            return cast<CTrackMania>(GetApp()).MenuManager.ManialinkScriptHandlerMenus.LocalUser.Name;
        } catch {}
        return "";
    }

    // The current server's GameTime
    uint get_GameTime() {
        return uint(GetApp().Network.PlaygroundClientScriptAPI.GameTime);
    }
}
