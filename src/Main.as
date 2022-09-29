HookRaceStatsEvents@ theHook = null;
[Setting hidden]
bool g_windowVisible = false;

UI::Font@ subheadingFont = UI::LoadFont("DroidSans.ttf", 18, -1, -1, true, true);

enum Cmp {Lt = -1, Eq = 0, Gt = 1}

/*

todo show green when players fin


 */
void Main() {
    MLHook::RequireVersionApi('0.2.0');
    startnew(InitCoro);
#if DEV
    // startnew(CheckVis);
#endif
}

void Update(float dt) {
    if (Setting_DrawTrails)
        DrawPlayers();
}

void InitCoro() {
    auto hook = HookRaceStatsEvents();
    @theHook = hook;
    startnew(CoroutineFunc(hook.MainCoro));
    MLHook::RegisterMLHook(hook, "RaceStats");
    MLHook::RegisterMLHook(hook, "RaceStats_ActivePlayers");
    yield();
    IO::FileSource refreshCode("RaceStatsFeed.Script.txt");
    string manialinkScript = refreshCode.ReadToEnd();
    yield();
    MLHook::InjectManialinkToPlayground("RaceStatsFeed", manialinkScript, true);
    //---------
    auto cotdHook = MLHook::DebugLogAllHook("MLHook_Event_CotdKoFeed");
    MLHook::RegisterMLHook(cotdHook, "CotdKoFeed_PlayerStatus");
    MLHook::RegisterMLHook(cotdHook, "CotdKoFeed_MatchKeyPair");
    IO::FileSource cotdML("CotdKoFeed.Script.txt");
    MLHook::InjectManialinkToPlayground("CotdKoFeed", cotdML.ReadToEnd(), true);
    startnew(CotdKoFeedMainCoro);
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

SortMethod[] AllSortMethods = {Race, TimeAttack};

[Setting hidden]
SortMethod g_sortMethod = SortMethod::TimeAttack;

void DrawMainInterior() {
    if (theHook is null) return;
    if (theHook.latestPlayerStats is null) return;
    if (theHook.sortedPlayers.Length == 0) return;

    UI::Text("" + theHook.sortedPlayers.Length + " Players / " + theHook.CpCount + " Checkpoints");

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

    // SizingFixedFit / fixedsame / strechsame / strechprop
    if (UI::BeginTable("player times", 5, UI::TableFlags::SizingStretchProp | UI::TableFlags::ScrollY)) {
        UI::TableSetupColumn("Pos.");
        UI::TableSetupColumn("Player");
        UI::TableSetupColumn("CP #");
        UI::TableSetupColumn("CP Lap Time");
        UI::TableSetupColumn("Best Time");
        UI::TableHeadersRow();

        for (uint i = 0; i < theHook.sortedPlayers.Length; i++) {
            uint colVars = 1;
            auto player = cast<PlayerCpInfo>(theHook.sortedPlayers[i]);
            if (player.cpCount > theHook.CpCount) { // finished
                UI::PushStyleColor(UI::Col::Text, vec4(.1, .9, .1, .85));
            } else if (player.name == LocalUserName) {
                UI::PushStyleColor(UI::Col::Text, vec4(.9, .1, .6, .85));
            } else {
                UI::PushStyleColor(UI::Col::Text, vec4(1, 1, 1, 1));
            }
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text("" + (i + 1) + ".");
            UI::TableNextColumn();
            UI::Text(player.name);
            UI::TableNextColumn();
            UI::Text('' + player.cpCount);
            UI::TableNextColumn();
            if (player.cpCount > 0) {
                UI::Text(MsToSeconds(player.lastCpTime));
            } else {
                UI::Text('---');
            }
            UI::TableNextColumn();
            auto bt = int(theHook.bestTimes[player.name]);
            if (bt > 0) {
                UI::Text(MsToSeconds(bt));
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
    PlayerCpInfo(MwFastBuffer<wstring> &in msg) {
        if (msg.Length < 4) {
            warn('PlayerCpInfo msg had insufficient length');
            return;
        }
        name = msg[0];
        cpCount = Text::ParseInt(msg[1]);
        lastCpTime = Text::ParseInt(msg[2]);
        bestTime = Text::ParseInt(msg[3]);
        if (theHook !is null) theHook.bestTimes[name] = bestTime;
    }
    int opCmp(PlayerCpInfo@ other) {
        return int(cmpPlayerCpInfo(this, other));
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
        UpdatePlayer(PlayerCpInfo(msg));
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

    void UpdatePlayer(PlayerCpInfo@ player) {
        @latestPlayerStats[player.name] = player;
        UpdateSortedPlayers();
    }

    void UpdateSortedPlayers() {
        sortedPlayers.RemoveRange(0, sortedPlayers.Length);
        auto ps = latestPlayerStats.GetKeys();
        for (uint i = 0; i < ps.Length; i++) {
            auto player = cast<PlayerCpInfo>(latestPlayerStats[ps[i]]);
            sortedPlayers.InsertLast(player);
        }
        sortedPlayers.SortAsc();
    }

    void UpdateActivePlayers(const string &in playersCsv, const string &in bestTimesCsv) {
        auto players = playersCsv.Split(",");
        auto newBestTimes = bestTimesCsv.Split(",");
        bestTimes.DeleteAll();
        for (uint i = 0; i < players.Length; i++) {
            auto bt = Text::ParseInt(newBestTimes[i]);
            bestTimes[players[i]] = bt;
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
        CpCount = 0;
        if (CurrentMap != "") {
            startnew(CoroutineFunc(SetCheckpointCount));
        }
        trails.DeleteAll();
        visLookup.DeleteAll();
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


#if DEV
void CheckVis() {
    // while (true) {
    //     yield();
    //     auto cpg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    //     while (cpg is null) {
    //         sleep(100);
    //         @cpg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    //     }
    //     while (cpg !is null) {
    //         auto nPlayers = cpg.Players.Length;
    //         auto scene = cpg.GameScene;
    //         if (scene is null) continue;
    //         auto zone = scene.HackScene.Sector.Zone;
    //         print('zone.DynamicLightArrays.Length: ' + zone.DynamicLightArrays.Length);
    //         auto pimp = zone.PImp;
    //         // pimp.LightDir_Lights[0] // some kind of global lighting
    //         // auto lights = pimp.LightDynamic_Frustum_Lights; -- openplanet complains, can't do `lbuffer`s
    //         print('pimp.LightDynamic_Frustum_Lights.Length: ' + pimp.LightDynamic_Frustum_Lights.Length);
    //         SLightDynaFrustum@[] justGoodLights;
    //         for (uint i = 0; i < pimp.LightDynamic_Frustum_Lights.Length; i++) {
    //             auto light = pimp.LightDynamic_Frustum_Lights[i];
    //             if (light.gxLight.IsOrtho) {
    //                 // mb good, Technique=GenShadowMask; iSG=3
    //                 // alt is 2dBallLight; iSG=0
    //                 justGoodLights.InsertLast(light);
    //             }
    //         }
    //         print('justGoodLights.Length: ' + justGoodLights.Length + ' == ' + nPlayers + ' nPlayers?');
    //         for (uint i = 0; i < justGoodLights.Length; i++) {
    //             auto light = justGoodLights[i];
    //             auto loc = light.Location;
    //             auto pos = vec3(loc.tx, loc.ty, loc.tz);
    //             print(pos.ToString());
    //         }
    //         sleep(1000);
    //     }
    // }
}


// auto nPlayers = cpg.Players.Length;

// array<PlayerTrail@> trails;
dictionary@ trails = dictionary();
dictionary@ visLookup = dictionary();

void DrawPlayers() {
    auto cpg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    if (cpg is null) return;
    auto scene = cpg.GameScene;
    auto players = cpg.Players;
    for (uint i = 0; i < players.Length; i++) {
        auto player = cast<CSmPlayer>(players[i]);
        if (player is null || player.User.Login == LocalUserLogin) continue;
        auto vis = cast<CSceneVehicleVis>(visLookup[player.User.Name]);
        if (vis is null) {
            @vis = VehicleState::GetVis(scene, player);
            @visLookup[player.User.Name] = vis;
        }
        if (vis is null) continue; // something went wrong
        // DrawIndicator(vis.AsyncState);
        // trail
        // print(player.User.Name);
        auto trail = cast<PlayerTrail>(trails[player.User.Name]);
        if (trail is null) {
            @trail = PlayerTrail();
            @trails[player.User.Name] = trail;
        }
        trail.AddPoint(vis.AsyncState.Position, vis.AsyncState.Dir, vis.AsyncState.Left);
        trail.DrawPath();
    }

    // probs a bit faster, but also draws ghosts
    // auto allVis = VehicleState::GetAllVis(scene);
    // // if (allVis.Length != trails.Length) trails.Resize()
    // for (uint i = 0; i < allVis.Length; i++) {
    //     DrawIndicator(allVis[i].AsyncState);
    //     // if (!trails.Exists())
    //     // CPlugVehicleVisModel
    //     print(allVis[i].Model.Id.Value);
    // }
}

void DrawIndicator(CSceneVehicleVisState@ vis) {
    if (Camera::IsBehind(vis.Position)) return;
    auto uv = Camera::ToScreenSpace(vis.Position); // possible div by 0
    auto gear = vis.CurGear;
    vec4 col;
    switch(gear) {
        case 0: col = vec4(.1, .1, .5, .5); break;
        case 1: col = vec4(.1, .4, .9, .5); break;
        case 2: col = vec4(.1, .9, .4, .5); break;
        case 3: col = vec4(.4, .9, .4, .5); break;
        case 4: col = vec4(.9, .4, .1, .5); break;
        case 5: col = vec4(.9, .1, .1, .5); break;
        default: col = vec4(.9, .1, .6, .5); print('unknown gear: ' + gear);
    }
    DrawPlayerIndicatorAt(uv, col);
}

void DrawPlayerIndicatorAt(vec2 uv, vec4 col) {
    nvg::BeginPath();
    nvg::RoundedRect(uv - vec2(20, 20)/2, vec2(20, 20), 4);
    nvg::FillColor(col);
    nvg::Fill();
    nvg::ClosePath();
}


void DrawPlayerIndicatorAt(vec2 uv) {
    nvg::BeginPath();
    nvg::RoundedRect(uv - vec2(20, 20)/2, vec2(20, 20), 4);
    nvg::FillColor(vec4(.99, .2, .92, .5));
    nvg::Fill();
}

#endif
