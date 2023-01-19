namespace MLFeed {
    /** deprecated: prefer `MLFeed::GetRaceData_V2()`
     * Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
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

    /**
     * Exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like.
     * Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)
     */
    const HookRaceStatsEventsBase_V2@ GetRaceData_V2() {
        return theHook;
    };

    /**
     * Exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like.
     * Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)
     */
    const HookRaceStatsEventsBase_V3@ GetRaceData_V3() {
        return theHook;
    };


    /**
     * Get a player's best CP times since the map loaded.
     * Deprecated: prefer PlayerCpInfo_V2.BestRaceTimes.
     */
    const array<uint>@ GetPlayersBestTimes(const string &in playerName) {
        return theHook.GetPlayersBestTimes(playerName);
    }

    /**
     * Your plugin's `KoDataProxy@` that exposes KO round information, and each player's spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    const KoDataProxy@ GetKoData() {
        auto plugin = Meta::ExecutingPlugin();
        KoDataProxy@ ret;
        if (!pluginToKoData.Get(plugin.ID, @ret)) {
            @ret = KoDataProxy(koFeedHook);
            @pluginToKoData[plugin.ID] = ret;
        }
        return ret;
    }

    /** Object exposing GhostInfos for each loaded ghost.
        This includes record ghosts loaded through the UI, and personal best ghosts.
        When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
        The list is cleared on map change. */
    const SharedGhostDataHook_V2@ GetGhostData() {
        return ghostHook;
    }

    /**
     * Object exposing info about the current Matchmaking Teams game.
     * Includes warm up, team points, player points, when new rounds begin, current MVP, players finished.
     */
    const HookTeamsMMEventsBase_V1@ GetTeamsMMData_V1() {
        return teamsFeed;
    }
}
