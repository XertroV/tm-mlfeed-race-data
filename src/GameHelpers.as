
const string MsToSeconds(int t) {
    return Text::Format("%.3f", float(t) / 1000.0);
}

CTrackMania@ get_app() {
    return cast<CTrackMania>(GetApp());
}

CGameManiaAppPlayground@ get_cmap() {
    return app.Network.ClientManiaAppPlayground;
}

CSmArenaInterfaceManialinkScripHandler@ get_pish() {
    if (GetApp().Network is null) return null;
    return cast<CSmArenaInterfaceManialinkScripHandler>(GetApp().Network.PlaygroundInterfaceScriptHandler);
}

string get_CurrentGameMode() {
    if (pish is null) return "";
    return pish.CurrentServerModeName;
}

bool get_IsGameModeCotdKO() {
    return CurrentGameMode == "TM_KnockoutDaily_Online"
        || CurrentGameMode == "TM_Knockout_Online";
}

// current playground
CSmArenaClient@ get_cp() {
    return cast<CSmArenaClient>(GetApp().CurrentPlayground);
}

CSmArena@ get_CP_Arena() {
    if (cp is null) return null;
    return cast<CSmArena>(cp.Arena);
}

CGameTerminal@ get_GameTerminal() {
    if (cp is null) return null;
    if (cp.GameTerminals.Length < 1) return null;
    return cp.GameTerminals[0];
}

CSmPlayer@ get_GUIPlayer() {
    if (GameTerminal is null) return null;
    return cast<CSmPlayer>(GameTerminal.GUIPlayer);
}
CSmPlayer@ get_ControlledPlayer() {
    if (GameTerminal is null) return null;
    return cast<CSmPlayer>(GameTerminal.ControlledPlayer);
}

CSmScriptPlayer@ get_GUIPlayer_ScriptAPI() {
    if (GUIPlayer is null) return null;
    return cast<CSmScriptPlayer>(GUIPlayer.ScriptAPI);
}
CSmScriptPlayer@ get_ControlledPlayer_ScriptAPI() {
    if (ControlledPlayer is null) return null;
    return cast<CSmScriptPlayer>(ControlledPlayer.ScriptAPI);
}

int get_CurrentRaceTime() {
    if (GUIPlayer_ScriptAPI !is null)
        return GUIPlayer_ScriptAPI.CurrentRaceTime;
    if (ControlledPlayer_ScriptAPI is null) return 0;
    return ControlledPlayer_ScriptAPI.CurrentRaceTime;
}
// int get_CurrentRaceTime() {
//     if (GUIPlayer_ScriptAPI is null) return null;
//     return GUIPlayer_ScriptAPI.CurrentRaceTime;
// }

string get_GUIPlayerUserLogin() {
    if (GUIPlayer is null) return "";
    return GUIPlayer.User.Login;
}
string get_GUIPlayerUserName() {
    if (GUIPlayer is null) return "";
    return GUIPlayer.User.Name;
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
