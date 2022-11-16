namespace MLFeed {
    /**
     * Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const RaceDataProxy@ GetRaceData() from "MLFeed";
    /**
     * Get a player's best CP times since the map loaded.
     */
    import const array<uint>@ GetPlayersBestTimes(const string &in playerName) from "MLFeed";

    /**
     * Your plugin's `KoDataProxy@` that exposes KO round information, and each player's , spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const KoDataProxy@ GetKoData() from "MLFeed";
    /** Object exposing GhostInfos for each loaded ghost.
        This includes record ghosts loaded through the UI, and personal best ghosts.
        When a ghost is *unloaded* from a map, it's info is not removed (it remains cached).
        Therefore, duplicate ghost infos may be recorded.
        The list is cleared on map change. */
    import const SharedGhostDataHook@ GetGhostData() from "MLFeed";
}
