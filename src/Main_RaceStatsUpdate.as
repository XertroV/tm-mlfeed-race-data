
namespace RaceFeed {
    MLFeed::PlayerCpInfo_V4@[] g_playerCpInfos;
    _PlayerCpInfo@[] playersJoined;
    _PlayerCpInfo@[] playersLeft;

    void Setup() {
        startnew(ClearCachedCSmPlayers).WithRunContext(Meta::RunContext::BeforeScripts);
        MLHook::RegisterPlaygroundMLExecutionPointCallback(RaceFeed::PlaygroundMLCallback);
    }

    void ResetState() {
        g_playerCpInfos.RemoveRange(0, g_playerCpInfos.Length);
        playersJoined.RemoveRange(0, playersJoined.Length);
        playersLeft.RemoveRange(0, playersLeft.Length);
    }

    //
    void ClearCachedCSmPlayers() {
        uint nbPlayers, i;
        while (true) {
            yield();
            nbPlayers = g_playerCpInfos.Length;
            for (i = 0; i < nbPlayers; i++) {
                // g_playerCpInfos[i].ResetUnsafeRefs();
                @g_playerCpInfos[i].Player = null;
                g_playerCpInfos[i].FieldsUpdated = MLFeed::PlayerUpdateFlags::None;
            }
            if (playersJoined.Length > 0) {
                playersJoined.RemoveRange(0, playersJoined.Length);
            }
            if (playersLeft.Length > 0) {
                playersLeft.RemoveRange(0, playersLeft.Length);
            }
        }
    }

    void PlaygroundMLCallback(ref@ meh) {
        auto app = GetApp();
        if (app.CurrentPlayground is null) return;
        if (app.CurrentPlayground.GameTerminals.Length < 1) return;
        // auto term = app.CurrentPlayground.GameTerminals[0];
        // auto player = cast<CSmPlayer>(term.ControlledPlayer);
        // if (player is null) return;
        // auto api = cast<CSmScriptPlayer>(player.ScriptAPI);
        // //trace('CPs: ' + api.RaceWaypointTimes.Length);
        auto cp = cast<CSmArenaClient>(app.CurrentPlayground);
        if (cp is null) return;
        SortPlayersAndUpdate(cp);
        theHook.DuplicateArraysForVersion1();
        // auto nbPlayers = cp.Players.Length;
        // for (uint i = 0; i < nbPlayers; i++) {
        //     auto p = cast<CSmPlayer>(cp.Players[i]);
        //     if (p is null) continue;
        //     auto api = cast<CSmScriptPlayer>(p.ScriptAPI);
        //     if (api is null || api.Score is null || api.User is null) continue;
        // }
    }


    void SortPlayersAndUpdate(CSmArenaClient@ cp) {
        auto nbPlayers = cp.Players.Length;
        bool playersChanged = nbPlayers != g_playerCpInfos.Length;
        // if (playersChanged) g_playerCpInfos.Reserve(nbPlayers);
        uint playerMwId;
        CSmPlayer@ gamePlayer;
        _PlayerCpInfo@ player;
        _PlayerCpInfo@ p2;
        uint j;

        //trace('Checking all players');

        for (uint i = 0; i < nbPlayers; i++) {
            @gamePlayer = cast<CSmPlayer>(cp.Players[i]);
            if (i >= g_playerCpInfos.Length) {
                // must be a new player
                @player = _PlayerCpInfo(gamePlayer);
                g_playerCpInfos.InsertLast(player);
                EmitGlobal_NewPlayer(player);
                trace('created new player: ' + player.ToString());
            } else {
                @player = cast<_PlayerCpInfo>(g_playerCpInfos[i]);
            }

            if (player is null) {
                // ~~end of the known list of players,~~
                throw("null player");
            }

            playerMwId = gamePlayer.Score.Id.Value;
            if (player.playerScoreMwId != playerMwId) {
                //trace('need to reorder @ ' + i);
                // need to reorder
                bool fixedReorder = false;
                for (j = i + 1; j < g_playerCpInfos.Length; j++) {
                    @p2 = cast<_PlayerCpInfo>(g_playerCpInfos[j]);
                    if (p2.playerScoreMwId == playerMwId) {
                        // found the player that should be here, swap with player
                        @g_playerCpInfos[j] = player;
                        @g_playerCpInfos[i] = p2;
                        @player = p2;
                        fixedReorder = true;
                        break;
                    }
                }
                if (!fixedReorder) {
                    // player is new
                    @player = _PlayerCpInfo(gamePlayer);
                    if (i == g_playerCpInfos.Length) {
                        g_playerCpInfos.InsertLast(player);
                    } else {
                        g_playerCpInfos.InsertAt(i, player);
                    }
                    EmitGlobal_NewPlayer(player);
                    trace('created new player b/c !fixedReorder: ' + player.ToString());
                }
            }

            // player and gamePlayer match
            if (player.playerScoreMwId != playerMwId) {
                throw("Player id mismatch: " + player.playerScoreMwId + " -> " + playerMwId);
            }

            // player.Reset();
            player.UpdateFromPlayer(gamePlayer);
        }

        // find players that left
        if (g_playerCpInfos.Length > nbPlayers) {
            for (uint i = nbPlayers; i < g_playerCpInfos.Length; i++) {
                @player = cast<_PlayerCpInfo>(g_playerCpInfos[i]);
                if (player is null) throw("null player");
                player.ResetUnsafeRefs();
                // auto ix = player.lastVehicleId & 0xFFFFFF;
                // if (ix < vehicleIdToPlayers.Length && vehicleIdToPlayers[ix] !is null) {
                //     if (vehicleIdToPlayers[ix].playerScoreMwId == player.playerScoreMwId) {
                //         @vehicleIdToPlayers[ix] = null;
                //     }
                // }
                EmitGlobal_PlayerLeft(player);
            }
            g_playerCpInfos.RemoveRange(nbPlayers, g_playerCpInfos.Length - nbPlayers);
        }
    }

    void EmitGlobal_NewPlayer(_PlayerCpInfo@ player) {
        playersJoined.InsertLast(player);
    }

    void EmitGlobal_PlayerLeft(_PlayerCpInfo@ player) {
        playersLeft.InsertLast(player);
        theHook.OnPlayerLeft(player);
    }
}
