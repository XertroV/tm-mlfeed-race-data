namespace ListUidsDemo {
    [Setting hidden]
    bool windowOpen = false;

    void Render() {
        if (!windowOpen) return;

        UI::SetNextWindowSize(500, 250, UI::Cond::Appearing);
        if (UI::Begin("ListUids Demo", windowOpen)) {
            auto listUids = MLFeed::Get_MapListUids_Receiver();
            UI::BeginDisabled(listUids.MapList_IsInProgress);
            if (UI::Button("Request UIDs")) {
                listUids.MapList_Request();
            }
            UI::EndDisabled();
            UI::Text("MapList_IsInProgress: " + listUids.MapList_IsInProgress);
            UI::Text("MsSinceLastReqStart: " + Time::Format(listUids.MsSinceLastReqStart));
            UI::Text("MsSinceLastReqEnd: " + Time::Format(listUids.MsSinceLastReqEnd));
            UI::Text("UpdateCount: " + listUids.UpdateCount);
            UI::Separator();
            UI::Text("UIDs & Names (" + listUids.MapList_MapUids.Length + "):");
            UI::Columns(2);
            for (uint i = 0; i < listUids.MapList_MapUids.Length; i++) {
                UI::Text(listUids.MapList_MapUids[i]);
            }
            UI::NextColumn();
            for (uint i = 0; i < listUids.MapList_MapUids.Length; i++) {
                UI::Text(listUids.MapList_Names[i]);
            }
            UI::Columns(1);
        }
        UI::End();

    }

    void RenderMenu() {
        if (UI::MenuItem("ListUids Demo", "", windowOpen)) {
            windowOpen = !windowOpen;
        }
    }
}
