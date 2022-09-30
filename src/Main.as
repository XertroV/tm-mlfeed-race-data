HookRaceStatsEvents@ theHook = null;
MLHook::DebugLogAllHook@ cotdHook = null;
[Setting hidden]
bool g_windowVisible = false;

UI::Font@ subheadingFont = UI::LoadFont("DroidSans.ttf", 18, -1, -1, true, true);

enum Cmp {Lt = -1, Eq = 0, Gt = 1}

/*

todo show green when players fin


 */
void Main() {
    MLHook::RequireVersionApi('0.2.1');
    startnew(InitCoro);
}

void OnDestroyed() { _Unload(); }
void OnDisabled() { _Unload(); }
void _Unload() {
    trace('_Unload, unloading hooks and removing injected ML');
    MLHook::UnregisterMLHooksAndRemoveInjectedML();
    // MLHook::UnregisterMLHookFromAll(theHook);
    // MLHook::UnregisterMLHookFromAll(cotdHook);
    // MLHook::RemoveInjectedMLFromPlayground("RaceStatsFeed");
    // MLHook::RemoveInjectedMLFromPlayground("CotdKoFeed");
}

void InitCoro() {
    HookRaceStatsEvents@ hook = HookRaceStatsEvents();
    @theHook = hook;
    MLHook::RegisterMLHook(theHook, "RaceStats");
    MLHook::RegisterMLHook(theHook, "RaceStats_ActivePlayers");
    // ml load
    yield();
    IO::FileSource refreshCode("RaceStatsFeed.Script.txt");
    string manialinkScript = refreshCode.ReadToEnd();
    MLHook::InjectManialinkToPlayground("RaceStatsFeed", manialinkScript, true);
    yield();
    // start coros
    startnew(CoroutineFunc(hook.MainCoro));
#if DEV
    // cotd hook setup
    @cotdHook = MLHook::DebugLogAllHook("MLHook_Event_CotdKoFeed");
    MLHook::RegisterMLHook(cotdHook, "CotdKoFeed_PlayerStatus");
    MLHook::RegisterMLHook(cotdHook, "CotdKoFeed_MatchKeyPair");
    // MLHook::RegisterMLHook(cotdHook, "RaceStats"); // bc its the debug hook
    // MLHook::RegisterMLHook(cotdHook, "RaceStats_ActivePlayers"); // bc its the debug hook
    // cotd ml
    IO::FileSource cotdML("CotdKoFeed.Script.txt");
    MLHook::InjectManialinkToPlayground("CotdKoFeed", cotdML.ReadToEnd(), true);
    startnew(CotdKoFeedMainCoro);
#endif
}

void RenderInterface() {
    if (!g_windowVisible) return;
    UI::PushFont(subheadingFont);
    if (UI::Begin("Race Stats", g_windowVisible, UI::WindowFlags::NoCollapse)) { // UI::WindowFlags::AlwaysAutoResize |
        DrawMainInterior();
    }
    UI::End();
    UI::PopFont();
}

void RenderMenu() {
    if (UI::MenuItem("\\$2f8" + Icons::ListAlt + "\\$z Race Stats", "", g_windowVisible)) {
        g_windowVisible = !g_windowVisible;
    }
}

enum SortMethod {
    Race, TimeAttack
}

/* with race, the winning players unspawn. how to differentiate?
maybe track *when* they unspawned, and group those.
so active racers get grouped with most recent unspawn.
then, when the respawn happens, racers all respawn at the same time,
so we can track the number of respawns
*/

SortMethod[] AllSortMethods = {Race, TimeAttack};

[Setting hidden]
SortMethod g_sortMethod = SortMethod::TimeAttack;
[Setting hidden]
bool Setting_ShowBestTimeCol = true;

vec4 finishColor = vec4(.2, 1, .2, .9);

vec4 ScaledCpColor(uint cp, uint totalCps) {
    float progress = float(cp) / float(totalCps + 1);
    return finishColor * progress + vec4(1,1,1,1) * (1 - progress);
}

void DrawMainInterior() {
    if (theHook is null) return;
    if (theHook.latestPlayerStats is null) return;
    if (theHook.sortedPlayers.Length == 0) return;

    UI::Text("" + theHook.sortedPlayers.Length + " Players  |  " + theHook.CPsToFinish + " Total Checkpoints");

    if (UI::BeginCombo("Sort Method", tostring(g_sortMethod))) {
        for (uint i = 0; i < AllSortMethods.Length; i++) {
            auto item = AllSortMethods[i];
            if (UI::Selectable(tostring(item), item == g_sortMethod)) {
                g_sortMethod = item;
                if (theHook !is null) theHook.UpdateSortedPlayers();
            }
        }
        UI::EndCombo();
    }

    Setting_ShowBestTimeCol = UI::Checkbox("Show Best Times?", Setting_ShowBestTimeCol);

    uint cols = 4;
    if (Setting_ShowBestTimeCol)
        cols++;

    // SizingFixedFit / fixedsame / strechsame / strechprop
    if (UI::BeginTable("player times", cols, UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY)) {
        UI::TableSetupColumn("Pos.");
        UI::TableSetupColumn("Player");
        UI::TableSetupColumn("CP #");
        UI::TableSetupColumn("CP Lap Time");
        if (Setting_ShowBestTimeCol)
            UI::TableSetupColumn("Best Time");
        UI::TableHeadersRow();

        for (uint i = 0; i < theHook.sortedPlayers.Length; i++) {
            uint colVars = 1;
            auto player = cast<PlayerCpInfo>(theHook.sortedPlayers[i]);
            if (player.spawnStatus != SpawnStatus::Spawned) {
                UI::PushStyleColor(UI::Col::Text, vec4(.3, .65, 1, .9));
            } else if (player.cpCount >= int(theHook.CPsToFinish)) { // finished 1-lap
                UI::PushStyleColor(UI::Col::Text, vec4(.2, 1, .2, .9));
            } else if (player.name == LocalUserName) {
                UI::PushStyleColor(UI::Col::Text, vec4(1, .3, .65, .9));
            } else {
                UI::PushStyleColor(UI::Col::Text, vec4(1, 1, 1, 1));
            }
            UI::TableNextRow();

            UI::TableNextColumn();
            UI::Text("" + (i + 1) + "."); // rank

            UI::TableNextColumn();
            UI::Text(player.name);

            UI::TableNextColumn();
            UI::PushStyleColor(UI::Col::Text, ScaledCpColor(player.cpCount, theHook.CPsToFinish));
            UI::Text('' + player.cpCount);
            UI::PopStyleColor();

            UI::TableNextColumn();
            if (player.cpCount > 0) {
                UI::Text(MsToSeconds(player.lastCpTime));
            } else {
                UI::Text('---');
            }

            if (Setting_ShowBestTimeCol) {
                UI::TableNextColumn();
                auto bt = int(player.bestTime);
                if (bt > 0) UI::Text(MsToSeconds(bt));
            }

            UI::PopStyleColor(colVars);
        }
        UI::EndTable();
    }
}

const string MsToSeconds(int t) {
    return Text::Format("%.3f", float(t) / 1000.0);
}

CTrackMania@ get_app() {
    return cast<CTrackMania>(GetApp());
}

CGameManiaAppPlayground@ get_cmap() {
    return app.Network.ClientManiaAppPlayground;
}


enum SpawnStatus {
    NotSpawned = 0,
    Spawning = 1,
    Spawned = 2
}


Cmp cmpPlayerCpInfo(PlayerCpInfo@ p1, PlayerCpInfo@ p2) {
    switch (g_sortMethod) {
        case SortMethod::Race: return cmpRace(p1, p2);
        case SortMethod::TimeAttack: return cmpTimeAttack(p1, p2);
        // default: break;
    }
    warn("Unknown sort method: " + tostring(g_sortMethod));
    return Cmp::Eq;
}


Cmp cmpRace(PlayerCpInfo@ p1, PlayerCpInfo@ p2) {
    // if we're in race mode, then we want to count the player as spawned if their spawnIndex == SpawnCounter
    SpawnStatus p1SS = p1.spawnStatus;
    SpawnStatus p2SS = p2.spawnStatus;
    if (theHook !is null) {
        if (p1.spawnStatus == SpawnStatus::NotSpawned && p1.spawnIndex == theHook.SpawnCounter)
            p1SS = SpawnStatus::Spawned;
        if (p2.spawnStatus == SpawnStatus::NotSpawned && p2.spawnIndex == theHook.SpawnCounter)
            p2SS = SpawnStatus::Spawned;
    }
    // spawned status dominates
    if (p1SS != p2SS) {
        // not spawned is smallest, so we want the opposite of cmpInt, so flip the args
        return cmpInt(int(p2SS), int(p1SS));
    }
    // if we have the same CPs, lowest time is better
    if (p1.cpCount == p2.cpCount)
        return cmpInt(p1.lastCpTime, p2.lastCpTime);
    // Lt => better ranking, so more CPs is better
    if (p1.cpCount > p2.cpCount) return Cmp::Lt;
    return Cmp::Gt;
}

Cmp cmpTimeAttack(PlayerCpInfo@ p1, PlayerCpInfo@ p2) {
    if (p1.bestTime == p2.bestTime) return cmpRace(p1, p2);
    if (p1.bestTime < 0) return Cmp::Gt;
    if (p2.bestTime < 0) return Cmp::Lt;
    if (p1.bestTime < p2.bestTime) return Cmp::Lt;
    return Cmp::Gt;
}

Cmp cmpInt(int a, int b) {
    if (a < b) return Cmp::Lt;
    if (a == b) return Cmp::Eq;
    return Cmp::Gt;
}

class PlayerCpInfo {
    string name;
    int cpCount;
    int lastCpTime;
    int bestTime;
    SpawnStatus spawnStatus;
    uint spawnIndex = 0;
    PlayerCpInfo(MwFastBuffer<wstring> &in msg, uint _spawnIndex) {
        spawnIndex = _spawnIndex;
        if (msg.Length < 5) {
            warn('PlayerCpInfo msg had insufficient length');
            return;
        }
        name = msg[0];
        cpCount = Text::ParseInt(msg[1]);
        lastCpTime = Text::ParseInt(msg[2]);
        bestTime = Text::ParseInt(msg[3]);
        spawnStatus = SpawnStatus(Text::ParseInt(msg[4]));
        if (theHook !is null) theHook.bestTimes[name] = bestTime;
    }
    int opCmp(PlayerCpInfo@ other) {
        return int(cmpPlayerCpInfo(this, other));
    }
    bool get_IsSpawned() {
        return spawnStatus == SpawnStatus::Spawned;
    }
}

class HookRaceStatsEvents : MLHook::HookMLEventsByType {
    HookRaceStatsEvents() {
        super("RaceStats");
    }

    MwFastBuffer<wstring>[] incoming_msgs;
    string lastMap;
    dictionary latestPlayerStats;
    dictionary bestTimes;
    array<PlayerCpInfo@> sortedPlayers;
    uint CpCount;
    uint LapCount;
    uint SpawnCounter = 0;

    void MainCoro() {
        sleep(50);
        MLHook::Queue_MessageManialinkPlayground("RaceStats", {"SendAllPlayerStates"});
        while (true) {
            yield();
            while (incoming_msgs.Length > 0) {
                ProcessMsg(incoming_msgs[incoming_msgs.Length - 1]);
                incoming_msgs.RemoveLast();
            }
            if (lastMap != CurrentMap) {
                lastMap = CurrentMap;
                OnMapChange();
            }
        }
    }

    void ProcessMsg(MwFastBuffer<wstring> &in msg) {
        UpdatePlayer(PlayerCpInfo(msg, SpawnCounter));
    }

    void OnEvent(const string &in type, MwFastBuffer<wstring> &in data) override {
        if (type.EndsWith("ActivePlayers")) {
            // update active player list
            UpdateActivePlayers(data[0], data[1]);
            return;
        }
        incoming_msgs.InsertLast(data);
    }

    /* main functionality logic */

    PlayerCpInfo@ GetPlayer(const string &in name) {
        return cast<PlayerCpInfo>(latestPlayerStats[name]);
    }

    void UpdatePlayer(PlayerCpInfo@ player) {
        // auto playerPrev = GetPlayer(player.name);
        // bool playerPrevWasNotSpawned = (playerPrev is null || playerPrev.spawnStatus != SpawnStatus::Spawned);
        if (player.spawnStatus == SpawnStatus::Spawned && player.cpCount == 0) {
            SpawnCounter += 1;
        }
        @latestPlayerStats[player.name] = player;
        // bugged on multilap
        // race events don't update the local players best time until they've respawned for some reason (other ppl are immediate)
        if (player.cpCount == this.CPsToFinish && player.name == LocalUserName && player.IsSpawned) {
            // note: this doesn't seem to really help
            player.bestTime = player.lastCpTime;
            bestTimes[player.name] = player.bestTime;
        }
        UpdateSortedPlayers();
    }

    void UpdateSortedPlayers() {
        sortedPlayers.RemoveRange(0, sortedPlayers.Length);
        auto ps = latestPlayerStats.GetKeys();
        for (uint i = 0; i < ps.Length; i++) {
            auto player = GetPlayer(ps[i]);
            sortedPlayers.InsertLast(player);
        }
        sortedPlayers.SortAsc();
    }

    void UpdateActivePlayers(const string &in playersCsv, const string &in bestTimesCsv) {
        auto players = playersCsv.Split(",");
        auto newBestTimes = bestTimesCsv.Split(",");
        bestTimes.DeleteAll();
        for (uint i = 0; i < players.Length; i++) {
            auto player = GetPlayer(players[i]);
            if (player !is null)
                bestTimes[players[i]] = player.bestTime;
            else {
                bestTimes[players[i]] = Text::ParseInt(newBestTimes[i]);
            }
        }
        auto prevPlayers = latestPlayerStats.GetKeys();
        for (uint i = 0; i < prevPlayers.Length; i++) {
            auto p = prevPlayers[i];
            if (!bestTimes.Exists(p)) {
                latestPlayerStats.Delete(p);
            }
        }
    }

    void OnMapChange() {
        latestPlayerStats.DeleteAll();
        sortedPlayers.RemoveRange(0, sortedPlayers.Length);
        this.CpCount = 0;
        if (CurrentMap != "") {
            startnew(CoroutineFunc(SetCheckpointCount));
        }
    }

    string get_CurrentMap() const {
        auto map = GetApp().RootMap;
        if (map is null) return "";
        // return map.EdChallengeId;
        return map.MapInfo.MapUid;
    }

    void SetCheckpointCount() {
        while (cp is null) {
            yield();
        }
        auto landmarks = cp.Arena.MapLandmarks;
        uint cpCount = 0;
        auto lcps = dictionary();
        for (uint i = 0; i < landmarks.Length; i++) {
            auto landmark = cast<CSmScriptMapLandmark>(landmarks[i]);
            if (landmark is null) continue;
            auto waypoint = landmark.Waypoint;
            if (waypoint is null || waypoint.IsMultiLap || waypoint.IsFinish) continue;
            if (landmark.Tag == "Checkpoint") {
                cpCount++;
                continue;
            }
            if (landmark.Tag == "LinkedCheckpoint") {
                lcps.Set('' + landmark.Order, true);
                continue;
            }
        }
        this.CpCount = cpCount + lcps.GetSize();
        this.LapCount = cp.Map.MapInfo.TMObjective_NbLaps;
    }

    uint get_CPsToFinish() {
        return (CpCount + 1) * LapCount;
    }
}


// current playground
CSmArenaClient@ get_cp() {
    return cast<CSmArenaClient>(GetApp().CurrentPlayground);
}

string _localUserLogin;
string get_LocalUserLogin() {
    if (_localUserLogin.Length == 0) {
        auto pcsa = GetApp().Network.PlaygroundClientScriptAPI;
        if (pcsa !is null && pcsa.LocalUser !is null) {
            _localUserLogin = pcsa.LocalUser.Login;
        }
    }
    return _localUserLogin;
}

string _localUserName;
string get_LocalUserName() {
    if (_localUserName.Length == 0) {
        auto pcsa = GetApp().Network.PlaygroundClientScriptAPI;
        if (pcsa !is null && pcsa.LocalUser !is null) {
            _localUserName = pcsa.LocalUser.Name;
        }
    }
    return _localUserName;
}
