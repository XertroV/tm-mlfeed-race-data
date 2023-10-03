const string NewRecordEvent = "TMGame_Record_NewRecord";

class HookRecordFeed : MLFeed::HookRecordEventsBase {
    private MLHook::PendingEvent@[] pendingEvents = {};
    private string lastMap = "";

    HookRecordFeed() {
        super(NewRecordEvent);
        startnew(CoroutineFunc(this.MainCoro));
    }

    void OnEvent(MLHook::PendingEvent@ event) override {
        pendingEvents.InsertLast(event);
    }

    void MainCoro() {
        while (true) {
            yield();
            while (pendingEvents.Length > 0) {
                auto event = pendingEvents[pendingEvents.Length - 1];
                pendingEvents.RemoveLast();
                ProcessEvent(event);
            }
            if (lastMap != CurrentMap) {
                lastMap = CurrentMap;
                OnMapChange();
            }
        }
    }

    void ProcessEvent(MLHook::PendingEvent@ event) {
        if (event.data.Length == 0) return;
        try {
            _lastRecordTime = Text::ParseInt(event.data[0]);
        } catch {
            warn("Failed to parse record time: " + event.data[0]);
        }
    }

    void OnMapChange() {
        _lastRecordTime = -1;
    }
}
