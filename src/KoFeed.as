namespace MLFeed {
    shared class KoEvent {
        string type;
        MwFastBuffer<wstring> data;
        KoEvent(const string &in t, MwFastBuffer<wstring> &in d) {
            type = t;
            data = d;
        }
    }

    shared class KoPlayerState {
        string name;
        bool isAlive = true;
        bool isDNF = false;
        KoPlayerState(const string &in n) {
            name = n;
        }
        KoPlayerState(const string &in n, bool alive, bool dnf) {
            name = n;
            isAlive = alive;
            isDNF = dnf;
        }
    }

    shared class HookKoStatsEventsBase : MLHook::HookMLEventsByType {
        HookKoStatsEventsBase(const string &in type) {
            super(type);
        }

        string lastGM;
        string lastMap;
        string[] players;

        int division = -1; // ServerNumber
        int mapRoundNb = -1;
        int mapRoundTotal = -1;
        int roundNb = -1;
        int roundTotal = -1;
        int playersNb = -1;
        int kosMilestone = -1;
        int kosNumber = -1;
        dictionary playerStates;

        KoPlayerState@ GetPlayerState(const string &in name) {
            return cast<KoPlayerState>(playerStates[name]);
        }
    }

    class HookKoStatsEvents : HookKoStatsEventsBase {
        HookKoStatsEvents() {
            super("KoFeed");
        }

        // most props defined in base
        KoEvent@[] incoming_msgs;

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

        void AskForAllPlayerStates() {
            MLHook::Queue_MessageManialinkPlayground(this.type, {"SendAllPlayerStates"});
        }

        void AskForAllMatchKeyPairs() {
            MLHook::Queue_MessageManialinkPlayground(this.type, {"SendAllMatchKeyPairs"});
        }

        void CheckGMChange() {
            if (lastGM != CurrentGameMode) {
                trace(this.type + ': GM change from: ' + lastGM + ' to ' + CurrentGameMode);
                lastGM = CurrentGameMode;
                MLHook::Queue_MessageManialinkPlayground(this.type, {"SetGameMode", lastGM});
                AskForAllMatchKeyPairs();
            }
        }

        void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override {
            incoming_msgs.InsertLast(KoEvent(type, data));
        }

        void ProcessMsg(KoEvent@ evt) {
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

        void UpdateMatchKeyPair(KoEvent@ evt) {
            if (evt.data.Length < 2) {
                warn('UpdateMatchKeyPair data too short.');
                return;
            }
            string key = evt.data[0];
            int value = Text::ParseInt(evt.data[1]);
            if (key == "ServerNumber") division = value;
            else if (key == "MapRoundNb") mapRoundNb = value;
            else if (key == "MapRoundTotal") mapRoundTotal = value;
            else if (key == "RoundNb") roundNb = value;
            else if (key == "RoundTotal") roundTotal = value;
            else if (key == "PlayersNb") playersNb = value;
            else if (key == "KOsMilestone") kosMilestone = value;
            else if (key == "KOsNumber") kosNumber = value;
            else {
                warn('got match key pair for unknown key: ' + key + ' w/ value: ' + value);
            }
        }

        // KoPlayerState@ GetPlayerState(const string &in name) {
        //     return cast<KoPlayerState>(playerStates[name]);
        // }

        void UpdatePlayerState(KoEvent@ evt) {
            if (evt.data.Length < 3) {
                warn('KO feed update player state got data with len ' + evt.data.Length + ' < 3');
                return;
            }
            string name = evt.data[0];
            bool alive = evt.data[1] == "True";
            bool dnf = evt.data[2] == "True";
            KoPlayerState@ ps;
            if (!playerStates.Get(name, @ps)) {
                @ps = KoPlayerState(name, alive, dnf);
                @playerStates[name] = ps;
                players.InsertLast(name);
                return;
            }
            ps.isAlive = alive;
            ps.isDNF = dnf;
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
    }
}
