// for TM_Teams_Matchmaking_Online.Script.txt
namespace TeamsFeed {
    const string Page_UID = "TeamsFeed";

    string lastGM;
    string lastMap;

    dictionary _players;

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
            @AllPlayers = array<MLFeed::MatchMakingPlayer_V1>();
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
            _players.DeleteAll();
            AllPlayers.RemoveRange(0, AllPlayers.Length);
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
            try {
                print('TeamsFeed event: ' + evt.type + '; ' + evt.data[0] + ": " + evt.data[1]);
            } catch {
                print('exception processing evt ' + getExceptionInfo());
            }
        }

        /* main functionality */

        void UpdateMatchKeyPair(MLHook::PendingEvent@ evt) {
            if (evt.data.Length < 2) {
                warn('UpdateMatchKeyPair data too short.');
                return;
            }
            string key = evt.data[0];
            if (key == "PlayerScore") UpdatePlayerScore(evt);
            else if (key.StartsWith("LR_")) UpdateLrKP(evt);
            else if (key.StartsWith("SAMI_")) UpdateSamiKP(evt);
            else if (key == "ClanScores") UpdateClanScores(evt);
            else {
                warn('got match key pair for unknown key: ' + key + ' w/ value: ' + evt.data[1]);
            }
        }

        MLFeed::MatchMakingPlayer_V1@ GetPlayer_V1(const string&in name) override {
            return cast<MLFeed::MatchMakingPlayer_V1>(_players[name]);
        }

        // Prefer GetRaceData_V3().SortedPlayers_Race_Respawns as a source of players. This list is not sorted and is generated on-demand.
        array<string>@ GetAllPlayerNames() override {
            return _players.GetKeys();
        }

        // See ComputeLatestRaceScores in Titles/Trackmania/Scripts/Libs/Nadeo/ModeLibs/TrackMania/Teams/TeamsCommon.Script.txt
        int[]@ ComputePoints(int[]@ finishedTeamOrder) override {
            if (PointsRepartition.Length == 0) return array<int>(finishedTeamOrder.Length);
            int minTeamPop = Math::Min(TeamPopulations[1], TeamPopulations[2]);
            int[] finishedCountByTeam = {0, 0, 0};
            int[] pointsRet;
            int teamCurrPop;
            int key = 0;
            int tn;
            for (uint i = 0; i < finishedTeamOrder.Length; i++) {
                tn = finishedTeamOrder[i];
                if (tn != 1 || tn != 2) {
                    pointsRet.InsertLast(0);
                    continue;
                }
                teamCurrPop = ++finishedCountByTeam[tn];
                if (teamCurrPop > minTeamPop) {
                    pointsRet.InsertLast(0);
                } else {
                    pointsRet.InsertLast(PointsRepartition[key]);
                    key += 1;
                }
            }
            if (key >= PointsRepartition.Length) return PointsRepartition[PointsRepartition.Length - 1];
            return PointsRepartition[key];
        }

        void UpdatePlayerScore(MLHook::PendingEvent@ evt) {
            auto @parts = string(evt.data[1]).Split(",");
            auto player = cast<PlayerMMInfo>(GetPlayer_V1(parts[0]));
            if (player is null) {
                auto newPlayer = PlayerMMInfo(parts);
                _players[parts[0]] = @newPlayer;
                AllPlayers.InsertLast(newPlayer);
                TeamPopulations[newPlayer.TeamNum]++;
            } else {
                auto oldTeam = player.TeamNum;
                player.UpdateFrom(parts);
                if (player.TeamNum != oldTeam) {
                    TeamPopulations[oldTeam]--;
                    TeamPopulations[player.TeamNum]++;
                }
            }
            // RecalcTeamPopulations();
        }

        void RecalcTeamPopulations() {
            for (uint i = 0; i < TeamPopulations.Length; i++) {
                TeamPopulations[i] = 0;
            }
            for (uint i = 0; i < AllPlayers.Length; i++) {
                TeamPopulations[AllPlayers[i].TeamNum]++;
            }
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

    class PlayerMMInfo : MLFeed::MatchMakingPlayer_V1 {
        PlayerMMInfo(array<string>@ parts) {
            UpdateFrom(parts);
        }

        void UpdateFrom(array<string>@ parts) {
            Name = parts[0];
            TeamNum = Text::ParseInt(parts[1]);
            RoundPoints = Text::ParseInt(parts[2]);
            Points = Text::ParseInt(parts[3]);
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
        UI::SetNextWindowSize(700, 500, UI::Cond::Appearing);
        int[] currOrder;
        for (uint i = 0; i < theHook.SortedPlayers_Race_Respawns.Length; i++) {
            auto item = theHook.SortedPlayers_Race_Respawns[i];
            currOrder.InsertLast(teamsFeed.GetPlayer_V1(item.Name).TeamNum);
        }
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
            UI::Text("ComputePoints(): " + IntsToStrs(teamsFeed.ComputePoints(currOrder)));
            UI::Separator();
            DrawPlayers();
        }
        UI::End();
    }

    const string IntsToStrs(int[]@ list) {
        if (list is null || list.Length == 0) return "";
        string ret;
        for (uint i = 0; i < list.Length; i++) {
            ret += list[i] + ", ";
        }
        return ret.SubStr(0, ret.Length - 2);
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
            auto playerCpInfo = players[i];
            auto playerMmInfo = teamsFeed.GetPlayer_V1(playerCpInfo.Name);
            int team = -1;
            int points = -1;
            int roundPoints = -1;
            if (playerMmInfo !is null) {
                team = playerMmInfo.TeamNum;
                points = playerMmInfo.Points;
                roundPoints = playerMmInfo.RoundPoints;
            }
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(playerCpInfo.Name);
            UI::TableNextColumn();
            UI::Text(tostring(team));
            UI::TableNextColumn();
            UI::Text(tostring(roundPoints));
            UI::TableNextColumn();
            UI::Text(tostring(points));
        }
    }
}
