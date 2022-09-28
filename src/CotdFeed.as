CSmArenaInterfaceManialinkScripHandler@ get_pish() {
    if (GetApp().Network is null) return null;
    return cast<CSmArenaInterfaceManialinkScripHandler>(GetApp().Network.PlaygroundInterfaceScriptHandler);
}

string get_CurrentGameMode() {
    if (pish is null) return "";
    return pish.CurrentServerModeName;
}

bool get_IsGameModeCotdKO() {
    return CurrentGameMode == "TM_KnockoutDaily_Online";
}

void CotdKoFeedMainCoro() {
    string lastGM;
    while (true) {
        sleep(40);
        if (lastGM != CurrentGameMode) {
            lastGM = CurrentGameMode;
            MLHook::Queue_MessageManialinkPlayground("CotdKoFeed", {"SetGameMode", lastGM});
        }
    }
}
