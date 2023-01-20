// for TM_Teams_Matchmaking_Online.Script.txt
namespace TeamsFeed {
    const string Page_UID = "TeamsFeed";

    string lastGM;
    string lastMap;

    class HookTeamsMMEvents : MLFeed::HookTeamsMMEventsBase_V1 {
        HookTeamsMMEvents() {
            super(Page_UID);
            @ClanScores = array<int>();
            ClanScores.Resize(31);
            @TeamPopulations = array<int>();
            TeamPopulations.Resize(31);
            @PointsRepartition = array<int>();
            @PlayersFinishedLogins = array<string>();
            @PlayersFinishedNames = array<string>();
        }

        // // override this method to avoid reload crash?
        // MLFeed::KoPlayerState@ GetPlayerState(const string &in name) override {
        //     // print("Getting state for: " + name + " exists? " + (playerStates.Exists(name) ? 'yes' : 'no'));
        //     if (playerStates.Exists(name))
        //         return cast<MLFeed::KoPlayerState>(playerStates[name]);
        //     return MLFeed::KoPlayerState(name, false, false);
        // }

        // most props defined in base
        MLHook::PendingEvent@[] incoming_msgs;

        void ResetState() {
            StartNewRace = -123;
            WarmUpIsActive = false;
            RankingMode = -1;
            MvpAccountId = "";
            MvpName = "";
            PlayersFinishedLogins.RemoveRange(0, PlayersFinishedLogins.Length);
            PlayersFinishedNames.RemoveRange(0, PlayersFinishedNames.Length);
            PlayerFinishedRaceUpdate = -1;
            PointsRepartition.RemoveRange(0, PointsRepartition.Length);
            RoundWinningClan = -1;
            RoundNumber = -1;
            PointsLimit = -1;
            TeamsUnbalanced = false;
            for (uint i = 0; i < ClanScores.Length; i++) {
                ClanScores[i] = 0;
                TeamPopulations[i] = 0;
            }
        }

        void MainCoro() {
            sleep(50);
            while (true) {
                yield();
                if (lastMap != CurrentMap) {
                    lastMap = CurrentMap;
                    if (lastMap == "")
                        OnMapChange(); // only reset status when the map gets set to null, not when it gets set to a map
                }
                CheckGMChange();
                while (incoming_msgs.Length > 0) {
                    ProcessMsg(incoming_msgs[incoming_msgs.Length - 1]);
                    incoming_msgs.RemoveLast();
                }
            }
        }

        void OnMapChange() {
            ResetState();
        }

        string get_CurrentMap() const {
            auto map = GetApp().RootMap;
            if (map is null) return "";
            return map.MapInfo.MapUid;
        }

        void CheckGMChange() {
            if (lastGM != CurrentGameMode) {
                lastGM = CurrentGameMode;
            }
        }

        string get_CurrentGameMode() {
            auto app = cast<CTrackMania>(GetApp());
            auto serverInfo = cast<CTrackManiaNetworkServerInfo>(app.Network.ServerInfo);
            if (serverInfo is null) return "";
            return serverInfo.CurGameModeStr;
        }

        void OnEvent(MLHook::PendingEvent@ event) override {
            incoming_msgs.InsertLast(event);
        }

        void ProcessMsg(MLHook::PendingEvent@ evt) {
            if (evt.type.EndsWith("MatchKeyPair")) {
                UpdateMatchKeyPair(evt);
            }
        }

        /* main functionality */

        void UpdateMatchKeyPair(MLHook::PendingEvent@ evt) {
            if (evt.data.Length < 2) {
                warn('UpdateMatchKeyPair data too short.');
                return;
            }
            string key = evt.data[0];
            if (key.StartsWith("LR_")) UpdateLrKP(evt);
            else if (key.StartsWith("SAMI_")) UpdateSamiKP(evt);
            else if (key == "ClanScores") UpdateClanScores(evt);
            else {
                warn('got match key pair for unknown key: ' + key + ' w/ value: ' + evt.data[1]);
            }
        }

        /**
         * Pass in a list of player.TeamNum for a finishing order, and 2 arrays that will be written to: the first will contain the points for each player, the second contains the total points for each team (length 3).
         *
         * Usage: teamPoints[player.TeamNum]
         *
         * Implementation reference: `ComputeLatestRaceScores` in `Titles/Trackmania/Scripts/Libs/Nadeo/ModeLibs/TrackMania/Teams/TeamsCommon.Script.txt`
         */
        void ComputePoints(const int[]@ finishedTeamOrder, int[]@ points, int[]@ teamPoints) const override {
            if (PointsRepartition.Length == 0 || finishedTeamOrder.Length == 0) {
                points.Resize(finishedTeamOrder.Length);
                teamPoints.Resize(3);
                for (int i = 0; i < Math::Max(points.Length, 3); i++) {
                    if (i < int(points.Length))
                        points[i] = 0;
                    if (i < 3)
                        teamPoints[i] = 0;
                }
                return;
            }
            int minTeamPop = Math::Min(TeamPopulations[1], TeamPopulations[2]);
            int[] finishedCountByTeam = {0, 0, 0};
            int teamCurrPop;
            int key = 0;
            int tn;
            // points.RemoveRange(0, points.Length);
            points.Resize(0);
            teamPoints.Resize(3);
            teamPoints[0] = 0; teamPoints[1] = 0; teamPoints[2] = 0;
            for (uint i = 0; i < finishedTeamOrder.Length; i++) {
                tn = finishedTeamOrder[i];
                if (tn != 1 && tn != 2) {
                    points.InsertLast(0);
                    continue;
                }
                teamCurrPop = ++finishedCountByTeam[tn];
                if (teamCurrPop > minTeamPop) {
                    points.InsertLast(0);
                } else if (key >= int(PointsRepartition.Length)) {
                    int p = PointsRepartition[PointsRepartition.Length - 1];
                    points.InsertLast(p);
                    teamPoints[tn] += p;
                } else {
                    int p = PointsRepartition[key];
                    points.InsertLast(p);
                    teamPoints[tn] += p;
                    key += 1;
                }
            }
            // print("minTeamPop: " + minTeamPop);
            // print("finishedCountByTeam: " + IntsToStrs(finishedCountByTeam));
            // print("points: " + IntsToStrs(points));
            // print("teamPoints: " + IntsToStrs(teamPoints));
        }

        void UpdateTeamsPopulation(int oldTeam, int newTeam) {
            if (oldTeam < 0) {
                TeamPopulations[newTeam]++;
            } else if (newTeam >= 0) {
                TeamPopulations[oldTeam]--;
                TeamPopulations[newTeam]++;
            }
            TeamsUnbalanced = TeamPopulations[1] != TeamPopulations[2];
        }

        void UpdateClanScores(MLHook::PendingEvent@ evt) {
            auto @parts = string(evt.data[1]).Split(',');
            auto nbParts = parts.Length;
            for (uint i = 0; i < ClanScores.Length; i++) {
                ClanScores[i] = i >= nbParts ? 0 : Text::ParseInt(parts[i]);
            }
        }

        void UpdateLrKP(MLHook::PendingEvent@ evt) {
            string key = evt.data[0];
            if (key == "LR_WarmUpIsActive") WarmUpIsActive = string(evt.data[1]) == "True";
            else if (key == "LR_RankingMode") RankingMode = Text::ParseInt(evt.data[1]);
            else if (key == "LR_StartNewRace") StartNewRace = Text::ParseInt(evt.data[1]);
            else if (key == "LR_PlayerFinishedRaceUpdate") PlayerFinishedRaceUpdate = Text::ParseInt(evt.data[1]);
            else if (key == "LR_PointsRepartition") UpdatePointsRepartition(evt);
            else if (key == "LR_PlayerFinishedRace") UpdatePlayersFinishedRace(evt);
            else if (key == "LR_PlayerFinishedRace_Names") UpdatePlayersFinishedRaceNames(evt);
            else if (key == "LR_MvpAccountId") UpdateMvp(evt);
            else warn("Unknown LR key: " + key);
        }

        void UpdatePointsRepartition(MLHook::PendingEvent@ evt) {
            auto @parts = string(evt.data[1]).Split(',');
            PointsRepartition.Resize(parts.Length);
            for (uint i = 0; i < parts.Length; i++) {
                PointsRepartition[i] = Text::ParseInt(parts[i]);
            }
        }

        void UpdatePlayersFinishedRace(MLHook::PendingEvent@ evt) {
            @PlayersFinishedLogins = string(evt.data[1]).Split(",");
        }

        void UpdatePlayersFinishedRaceNames(MLHook::PendingEvent@ evt) {
            @PlayersFinishedNames = string(evt.data[1]).Split(",");
        }

        void UpdateMvp(MLHook::PendingEvent@ evt) {
            auto @parts = string(evt.data[1]).Split(",");
            MvpName = parts[0];
            MvpAccountId = parts[1];
            for (uint i = 0; i < theHook._SortedPlayers_Race_Respawns.Length; i++) {
                cast<RaceFeed::_PlayerCpInfo>(theHook._SortedPlayers_Race_Respawns[i]).IsMVP = false;
            }
            auto mvpPlayer = theHook._GetPlayer(MvpName);
            if (mvpPlayer !is null) mvpPlayer.IsMVP = true;
        }

        void UpdateSamiKP(MLHook::PendingEvent@ evt) {
            string key = evt.data[0];
            int val = Text::ParseInt(evt.data[1]);
            if (key == "SAMI_RoundWinningClan") RoundWinningClan = val;
            else if (key == "SAMI_RoundNumber") RoundNumber = val;
            else if (key == "SAMI_PointsLimit") PointsLimit = val;
            else warn("Unknown SAMI key: " + key);
        }
    }

    bool DemoUIOpen = false;

    void RenderMenu() {
        if (UI::MenuItem(Icons::Rss + " Teams / MM Demo", "", DemoUIOpen)) {
            DemoUIOpen = !DemoUIOpen;
        }
    }

    void RenderDemoUI() {
        if (!DemoUIOpen) return;
        UI::SetNextWindowSize(300, 600, UI::Cond::Appearing);
        int[] currOrder;
        for (uint i = 0; i < theHook.SortedPlayers_Race_Respawns.Length; i++) {
            currOrder.InsertLast(cast<RaceFeed::_PlayerCpInfo>(theHook.SortedPlayers_Race_Respawns[i]).TeamNum);
        }
        int[] points;
        int[] teamPoints;
        teamsFeed.ComputePoints(currOrder, points, teamPoints);
        if (UI::Begin("Teams Feed Demo UI", DemoUIOpen)) {
            UI::Text("WarmUpIsActive: " + tostring(teamsFeed.WarmUpIsActive));
            UI::Text("RankingMode: " + teamsFeed.RankingMode);
            UI::Text("PointsLimit: " + teamsFeed.PointsLimit);
            UI::Text("PointsRepartition: " + IntsToStrs(teamsFeed.PointsRepartition));
            UI::Text("StartNewRace: " + teamsFeed.StartNewRace);
            UI::Text("RoundNumber: " + teamsFeed.RoundNumber);
            UI::Text("PlayerFinishedRaceUpdate: " + teamsFeed.PlayerFinishedRaceUpdate);
            UI::Text("PlayersFinished: " + string::Join(teamsFeed.PlayersFinishedNames, ", "));
            UI::Text("MvpAccountId: " + teamsFeed.MvpAccountId);
            UI::Text("MvpName: " + teamsFeed.MvpName);
            UI::Text("RoundWinningClan: " + teamsFeed.RoundWinningClan);
            UI::Text("Blue Score: " + teamsFeed.ClanScores[1]);
            UI::Text("Red Score: " + teamsFeed.ClanScores[2]);
            UI::Text("ClanScores: " + IntsToStrs(teamsFeed.ClanScores));
            UI::Text("ComputePoints() Finish Order Input: " + IntsToStrs(currOrder));
            UI::Text("ComputePoints() Points: " + IntsToStrs(points));
            UI::Text("ComputePoints() TeamPoints: " + IntsToStrs(teamPoints));
            UI::Text("TeamPopulations: " + IntsToStrs(teamsFeed.TeamPopulations));
            UI::Separator();
            DrawPlayers();
        }
        UI::End();
    }

    void DrawPlayers() {
        if (UI::BeginTable("teams players demo", 4, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("TeamNum");
            UI::TableSetupColumn("RoundPoints");
            UI::TableSetupColumn("Points");
            UI::TableHeadersRow();
            DrawPlayersTableInner();
            UI::EndTable();
        }
    }

    void DrawPlayersTableInner() {
        auto @players = theHook.SortedPlayers_Race_Respawns;
        for (uint i = 0; i < players.Length; i++) {
            auto playerCpInfo = cast<RaceFeed::_PlayerCpInfo>(players[i]);
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(playerCpInfo.Name);
            UI::TableNextColumn();
            UI::Text(tostring(playerCpInfo.TeamNum));
            UI::TableNextColumn();
            UI::Text(tostring(playerCpInfo.RoundPoints));
            UI::TableNextColumn();
            UI::Text(tostring(playerCpInfo.Points));
        }
    }
}

const string IntsToStrs(int[]@ list) {
    if (list is null || list.Length == 0) return "";
    string ret;
    for (uint i = 0; i < list.Length; i++) {
        ret += list[i] + ", ";
    }
    return ret.SubStr(0, ret.Length - 2);
}
