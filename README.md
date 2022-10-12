# MLFeed: Race Data

This plugin provides other plugins with data about the current race. You might need to install it to make other plugins work.

*Requires MLHook (you need to install that plugin too)*

## For Developers

Currently exposed data:
* Sorted Player data
	* For each player: LatestCPTime, CPCount, Cached Previous CP Times, Spawn Status, Best Time
	* Sort methods: TimeAttack (sort by best time), Race (sorted by race leader)
* Knockout data (for COTD / KO)
  * Per-Player Alive and DNF status
	* Total Rounds, Current Round, Alive Players, Number of KOs This Round, Next KO Milestone, Number of Players (originally)

Additional data exposure available upon request.

### Using MLFeed: Race Data

Example plugins:

- https://github.com/XertroV/tm-cotd-buffer-time
- https://github.com/XertroV/tm-race-stats/
- https://github.com/XertroV/tm-too-many-ghosts
- https://github.com/XertroV/tm-somewhat-better-records/ (older example)

include this in your `info.toml` file:

```toml
[script]
dependencies = ["MLHook", "MLFeedRaceData"] # need both
```

see also: [https://openplanet.dev/docs/reference/info-toml](https://openplanet.dev/docs/reference/info-toml)

## Boring Stuff

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-mlfeed-race-data](https://github.com/XertroV/tm-mlfeed-race-data)

GL HF
