# Upgrade Guide for v0.4

All types and functions should be prefixed with `MLFeed::`.

## Features in v0.4

* Race_Respawns
* add respawn data for all players
  * note: for non-local players these figures are an estimate; times are exact for the local player
  * last respawn time
  * last respawn cp
  * time lost to respawn in total and by cp
  * number of respawns
* player
  * is local player: bool
  * start time
  * current race time (per player, both raw and accounting for lag)
  * latency info

## Replacements

You should mostly be able to find and replace these things to begin using the new types that expose the new data.

### function calls / properties

- `GetRaceData()` with `GetRaceData_V2()`
- `raceData.GetPlayer(name)` with `raceData.GetPlayer_V2(name)`
- `ghostData.Ghosts` with `ghostData.Ghosts_V2`

### types

- `RaceDataProxy` with `HookRaceStatsEventsBase_V2`
- `HookRaceStatsEventsBase` with `HookRaceStatsEventsBase_V2`
- `PlayerCpInfo` with `PlayerCpInfo_V2`
- `SharedGhostDataHook` with `SharedGhostDataHook_V2`
- `GhostInfo` with `GhostInfo_V2`

### deprecations

- Instead of `GetPlayersBestTimes(name)`, prefer `GetPlayer_V2(name).BestRaceTimes`
