namespace MLFeed {
    /**
     * Your plugin's `RaceDataProxy@` that exposes checkpoint data, spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const RaceDataProxy@ GetRaceData() from "MLFeed";
    /**
     * Your plugin's `KoDataProxy@` that exposes KO round information, and each player's , spawn info, and lists of players for each sorting method.
     * You can call this function as often as you like -- it will always return the same proxy instance based on plugin ID.
     */
    import const KoDataProxy@ GetKoData() from "MLFeed";
}
