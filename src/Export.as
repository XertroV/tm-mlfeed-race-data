namespace MLFeed {
    /**
     * Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const RaceDataProxy@ GetRaceData() from "MLFeed";
    /**
     * Exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like.
     * Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)
     */
    import const HookRaceStatsEventsBase_V2@ GetRaceData_V2() from "MLFeed";
    /**
     * Exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like.
     * Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)
     */
    import const HookRaceStatsEventsBase_V3@ GetRaceData_V3() from "MLFeed";
    /**
     * Exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like.
     * Backwards compatible with RaceDataProxy (except that it's a different type; properties/methods are the same, though.)
     */
    import const HookRaceStatsEventsBase_V4@ GetRaceData_V4() from "MLFeed";

    /**
     * Get a player's best CP times since the map loaded.
     * Deprecated: prefer PlayerCpInfo_V2.BestRaceTimes.
     */
    import const array<uint>@ GetPlayersBestTimes(const string &in playerName) from "MLFeed";

    /**
     * Your plugin's `KoDataProxy@` that exposes KO round information, and each player's spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const KoDataProxy@ GetKoData() from "MLFeed";

    /** Object exposing GhostInfos for each loaded ghost.
        This includes record ghosts loaded through the UI, and personal best ghosts.
        When a ghost is *unloaded* from a map, its info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded (though measures are taken to prevent this).
        The list is cleared on map change. */
    import const SharedGhostDataHook_V2@ GetGhostData() from "MLFeed";

    /**
     * Object exposing info about the current Matchmaking Teams game.
     * Includes warm up, team points, when new rounds begin, current MVP, players finished, and points prediction.
     */
    import const HookTeamsMMEventsBase_V1@ GetTeamsMMData_V1() from "MLFeed";
}
