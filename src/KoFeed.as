namespace KoFeed {
    const string KOsEvent = "MLFeedKOs";

    class HookKoStatsEvents : MLFeed::HookKoStatsEventsBase {
        HookKoStatsEvents() {
            super(KOsEvent);
        }

        // override this method to avoid reload crash?
        MLFeed::KoPlayerState@ GetPlayerState(const string &in name) override {
            // print("Getting state for: " + name + " exists? " + (playerStates.Exists(name) ? 'yes' : 'no'));
            if (playerStates.Exists(name))
                return cast<MLFeed::KoPlayerState>(playerStates[name]);
            return MLFeed::KoPlayerState(name, false, false);
        }

        // most props defined in base
        MLHook::PendingEvent@[] incoming_msgs;

        void ResetState() {
            division = -1;
            mapRoundNb = -1;
            mapRoundTotal = -1;
            roundNb = -1;
            roundTotal = -1;
            playersNb = -1;
            kosMilestone = -1;
            kosNumber = -1;
            playerStates.DeleteAll();
            players.RemoveRange(0, players.Length);
        }

        void MainCoro() {
            sleep(50);
            AskForAllPlayerStates();
            AskForAllMatchKeyPairs();
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
            AskForAllMatchKeyPairs();
        }

        string get_CurrentMap() const {
            auto map = GetApp().RootMap;
            if (map is null) return "";
            // return map.EdChallengeId;
            return map.MapInfo.MapUid;
        }

        void CheckGMChange() {
            if (lastGM != CurrentGameMode) {
                trace(this.type + ': GM change from: ' + lastGM + ' to ' + CurrentGameMode);
                lastGM = CurrentGameMode;
                MLHook::Queue_MessageManialinkPlayground(this.type, {"SetGameMode", lastGM});
                AskForAllMatchKeyPairs();
            }
        }

        string get_CurrentGameMode() {
            auto app = cast<CTrackMania>(GetApp());
            auto serverInfo = cast<CTrackManiaNetworkServerInfo>(app.Network.ServerInfo);
            if (serverInfo is null) return "";
            return serverInfo.CurGameModeStr;
        }


        void AskForAllPlayerStates() {
            MLHook::Queue_MessageManialinkPlayground(this.type, {"SendAllPlayerStates"});
        }

        void AskForAllMatchKeyPairs() {
            MLHook::Queue_MessageManialinkPlayground(this.type, {"SendAllMatchKeyPairs"});
        }

        void OnEvent(MLHook::PendingEvent@ event) override {
            incoming_msgs.InsertLast(event);
        }

        void ProcessMsg(MLHook::PendingEvent@ evt) {
            if (evt.type.EndsWith("PlayerStatus")) {
                UpdatePlayerState(evt);
                return;
            } else if (evt.type.EndsWith("MatchKeyPair")) {
                UpdateMatchKeyPair(evt);
            } else {
                warn('Skipping event: "' + evt.type + '"');
            }
        }

        /* main functionality */

        void UpdateMatchKeyPair(MLHook::PendingEvent@ evt) {
            if (evt.data.Length < 2) {
                warn('UpdateMatchKeyPair data too short.');
                return;
            }
            string key = evt.data[0];
            int value = Text::ParseInt(evt.data[1]);
            if (key == "ServerNumber") division = (value + 1); // server number offset by 1
            else if (key == "MapRoundNb") mapRoundNb = value;
            else if (key == "MapRoundTotal") mapRoundTotal = value;
            else if (key == "RoundNb") roundNb = value;
            else if (key == "RoundTotal") roundTotal = value;
            else if (key == "PlayersNb") playersNb = value;
            else if (key == "KOsMilestone") kosMilestone = value;
            else if (key == "RankingUpdate") { /* nothing */ }
            else if (key == "KOsNumber") kosNumber = value;
            else {
                warn('got match key pair for unknown key: ' + key + ' w/ value: ' + value);
            }
        }

        void UpdatePlayerState(MLHook::PendingEvent@ evt) {
            if (evt.data.Length < 3) {
                warn('KO feed update player state got data with len ' + evt.data.Length + ' < 3');
                return;
            }
            string name = evt.data[0];
            bool alive = evt.data[1] == "True";
            bool dnf = evt.data[2] == "True";
            MLFeed::KoPlayerState@ ps;
            if (!playerStates.Get(name, @ps)) {
                @ps = MLFeed::KoPlayerState(name, alive, dnf);
                @playerStates[name] = ps;
                players.InsertLast(name);
                return;
            }
            ps.isAlive = alive;
            ps.isDNF = dnf;
        }
    }
}
