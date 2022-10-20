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
* The last record set by the current player

Additional data exposure available upon request.

### Using MLFeed: Race Data

Example plugins:

- https://github.com/XertroV/tm-cotd-buffer-time
- https://github.com/XertroV/tm-race-stats/

include this in your `info.toml` file:

```toml
[script]
dependencies = ["MLHook", "MLFeedRaceData"] # need both
```

see also: [https://openplanet.dev/docs/reference/info-toml](https://openplanet.dev/docs/reference/info-toml)

```AngelScript

```

[Exported functions (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/Export.as)

[Exported classes (https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)](https://github.com/XertroV/tm-mlfeed-race-data/blob/master/src/ExportShared.as)

[Example Usage](https://github.com/XertroV/tm-cotd-buffer-time/blob/57ee1bce5ccd115a0ebef2a9b23f72d77cbfa28a/src/KoBufferDisplay.as#L132-L133)

*Still curious about how to use something? Read the examples and use github search to find usages! Still not sure? Ask @XertroV on the Openplanet Discord*

## Boring Stuff

License: Public Domain

Authors: XertroV

Suggestions/feedback: @XertroV on Openplanet discord

Code/issues: [https://github.com/XertroV/tm-mlfeed-race-data](https://github.com/XertroV/tm-mlfeed-race-data)

GL HF

-----

todo:

* look into teams data, e.g. during ranked modes
