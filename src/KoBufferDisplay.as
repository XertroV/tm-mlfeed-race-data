namespace KoBuffer {
    void Main() {
        startnew(InitCoro);
    }

    void InitCoro() {
        startnew(MainCoro);
    }

    void MainCoro() {
        while (true) {
            yield();
            CheckGMChange();
        }
    }

    string lastGM = "nonexistent init";
    void CheckGMChange() {
        if (CurrentGameMode != lastGM) {
            lastGM = CurrentGameMode;
            // if (IsGameModeCotdKO) {
            // }
        }
    }

    bool get_IsGameModeCotdKO() {
        return lastGM == "TM_KnockoutDaily_Online"
            || lastGM == "TM_Knockout_Online";
    }
}

namespace KoBufferUI {
    [Setting hidden]
    bool g_koBufferUIVisible = true;
    // const string menuIcon = Icons::ArrowsH;
    const string menuIcon = " Δt";

    int boldItalicDisplayFont = nvg::LoadFont("fonts/MontserratMono-BoldItalic.ttf", true, true);
    int boldDisplayFont = nvg::LoadFont("fonts/MontserratMono-Bold.ttf", true, true);
    // int bufferDisplayFont = nvg::LoadFont("DroidSans.ttf", true, true);

#if DEV
    PlayerCpInfo@ testInfo;
    uint lastPlayerCp = 0;
#endif

    void RenderMenu() {
        if (UI::MenuItem("\\$faa\\$s" + menuIcon + "\\$z COTD Buffer Time", MenuShortcutStr, g_koBufferUIVisible)) {
            g_koBufferUIVisible = !g_koBufferUIVisible;
        }
    }

    [Setting category="KO Buffer Time" name="Use Italic Font?"]
    bool Setting_BufferFontItalic = false;

    int get_bufferDisplayFont() {
        if (Setting_BufferFontItalic) return boldItalicDisplayFont;
        return boldDisplayFont;
    }

    void Render() {
        if (!g_koBufferUIVisible) return;
        if (!KoBuffer::IsGameModeCotdKO) return;
        // calc player's position relative to ko position
        // target: either player right before or after ko pos
        if (koFeedHook is null || theHook is null) return;
        // string localUser = LocalUserName;
        string localUser = GUIPlayerUserName;
        uint localUserRank = 0;
        uint nPlayers = koFeedHook.playersNb;
        uint nKOs = koFeedHook.kosNumber;
        uint preCutoffRank = nPlayers - nKOs;
        uint postCutoffRank = preCutoffRank + 1;
        PlayerCpInfo@ preCpInfo = null;
        PlayerCpInfo@ postCpInfo = null;
        PlayerCpInfo@ localPlayer = null;
        g_sortMethod = SortMethod::Race;

        for (uint i = 0; i < theHook.sortedPlayers.Length; i++) {
            // uint currRank = i + 1;
            auto player = theHook.sortedPlayers[i];
            if (player is null) continue; // edge case on changing maps and things
            if (player.name == localUser) @localPlayer = player;
            if (player.lastRank == preCutoffRank) @preCpInfo = player;
            if (player.lastRank == postCutoffRank) @postCpInfo = player;
        }

        if (localPlayer is null) return;
#if DEV
        if (preCpInfo is null && localPlayer !is null) warn("preCpInof null but player not null!");
        if (nPlayers == 1 && postCpInfo is null && preCpInfo !is null) {
            if (testInfo is null || lastPlayerCp != localPlayer.cpCount) {
                lastPlayerCp = localPlayer.cpCount;
                int randAdjust = Math::Rand(-150, 150);
                int offset = randAdjust > 75 ? -1 : 0;
                @testInfo = PlayerCpInfo(localPlayer, offset);
                testInfo.lastCpTime += randAdjust;
                testInfo.cpTimes[testInfo.cpCount] += randAdjust;
                testInfo.lastRank += (randAdjust < 0) ? 0 : 2;
                warn('player: ' + localPlayer.ToString());
                warn('adding postCpInfo: ' + testInfo.ToString());
            }
            @postCpInfo = testInfo;
            @preCpInfo = testInfo;
        }
#endif
        if (localPlayer is null || preCpInfo is null || postCpInfo is null) {
#if DEV
            trace('a cp time player was null!');
#endif
            return;
        }

        PlayerCpInfo@ targetCpInfo;
        int msDelta;
        bool isBehind;
        bool sameCp;

        // ahead of 1st player to be eliminated?
        if (localPlayer.lastRank < postCpInfo.lastRank) @targetCpInfo = postCpInfo;
        else @targetCpInfo = preCpInfo; // otherwise, if at risk of elim
        isBehind = localPlayer.lastRank > targetCpInfo.lastRank; // should never be ==
        // are we at same CP?
        sameCp = localPlayer.cpCount == targetCpInfo.cpCount;
        // if so, ms delta trivial to calculate
        if (sameCp)
            msDelta = Math::Abs(localPlayer.lastCpTime - targetCpInfo.lastCpTime);
        else { // otherwise, we're at least (GameTime - player[cp]) ahead/behind
            uint cpToCompare = Math::Min(targetCpInfo.cpCount, localPlayer.cpCount);
            if (isBehind)
                msDelta = CurrentRaceTime - targetCpInfo.cpTimes[cpToCompare];
            else
                msDelta = CurrentRaceTime - localPlayer.cpTimes[cpToCompare];
        }

        vec4 bufColor = GetBufferTimeColor(sameCp, isBehind);

        DrawBufferTime(msDelta, isBehind, bufColor);
    }

    [Setting category="KO Buffer Time" name="Display Font Size" min="10" max="150"]
    float Setting_BufferFontSize = 60;

    [Setting drag category="KO Buffer Time" name="Display Position" description="Origin: Top left. Values: Proportion of screen (range: 0-100 %)"]
    vec2 Setting_BufferDisplayPosition = vec2(50, 87);

    void DrawBufferTime(int msDelta, bool isBehind, vec4 bufColor) {
        nvg::Reset();
        string toDraw = (isBehind ? "-" : "+") + MsToSeconds(msDelta);
        auto screen = vec2(Draw::GetWidth(), Draw::GetHeight());
        vec2 pos = (screen * Setting_BufferDisplayPosition / vec2(100, 100));// - (size / 2);

        nvg::FontFace(bufferDisplayFont);
        nvg::FontSize(Setting_BufferFontSize);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        auto sizeWPad = nvg::TextBounds(toDraw.SubStr(0, toDraw.Length - 3) + "000") + vec2(20, 10);

        if (Setting_DrawBufferTimeBG) {
            nvg::BeginPath();
            nvg::FillColor(Setting_BufferTimeBGColor);
            nvg::Rect(pos - sizeWPad / 2, sizeWPad);
            nvg::Fill();
            nvg::ClosePath();
        }

        nvg::FillColor(bufColor);
        nvg::Text(pos, toDraw);
    }

    [Setting color category="KO Buffer Time" name="Color: Ahead w/in 1 CP"]
    vec4 Col_AheadDefinite = vec4(0, .7, 0, 1);
    [Setting color category="KO Buffer Time" name="Color: Behind w/in 1 CP"]
    vec4 Col_BehindDefinite = vec4(0.629f, 0.000f, 0.000f, 1.000f);

    [Setting color category="KO Buffer Time" name="Color: Far Ahead (actively counts)"]
    vec4 Col_FarAhead = vec4(0.082f, 0.533f, 0.082f, 0.800f);
    [Setting color category="KO Buffer Time" name="Color: Far Behind (actively counts)"]
    vec4 Col_FarBehind = vec4(0.873f, 0.145f, 0.145f, 0.800f);

    [Setting category="KO Buffer Time" name="Enable Buffer Time BG Color"]
    bool Setting_DrawBufferTimeBG = true;
    [Setting color category="KO Buffer Time" name="Buffer Time BG Color" description="Add a background to the timer"]
    vec4 Setting_BufferTimeBGColor = vec4(0,0,0,.25);

    vec4 GetBufferTimeColor(bool sameCp, bool isBehind) {
        return sameCp
            ? (isBehind ? Col_BehindDefinite : Col_AheadDefinite)
            : (isBehind ? Col_FarBehind : Col_FarAhead);
    }

    [Setting category="KO Buffer Time" name="Shortcut Key Enabled?"]
    bool Setting_ShortcutKeyEnabled = false;

    [Setting category="KO Buffer Time" name="Shortcut Key Choice"]
    VirtualKey Setting_ShortcutKey = VirtualKey::F5;

    string get_MenuShortcutStr() {
        if (Setting_ShortcutKeyEnabled)
            return tostring(Setting_ShortcutKey);
        return "";
    }

    UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
        if (Setting_ShortcutKeyEnabled && down && key == Setting_ShortcutKey) {
            g_koBufferUIVisible = !g_koBufferUIVisible;
        }
        return UI::InputBlocking::DoNothing;
    }
}
