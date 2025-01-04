namespace ListUidsDemo {
    [Setting hidden]
    bool windowOpen = false;

    string m_NbMapUidsToRequest = "25";

    void Render() {
        if (!windowOpen) return;

        UI::SetNextWindowSize(550, 250, UI::Cond::FirstUseEver);
        if (UI::Begin("ListUids Demo", windowOpen)) {
            auto listUids = MLFeed::Get_MapListUids_Receiver();
            UI::BeginDisabled(listUids.MapList_IsInProgress);
            bool btnPress = UI::Button("Request UIDs");
            UI::SameLine();
            UI::SetNextItemWidth(60);
            bool changed = false;
            m_NbMapUidsToRequest = UI::InputText("Max Uids (Min 25)##NbMapUidsToRequest", m_NbMapUidsToRequest, changed, UI::InputTextFlags::EnterReturnsTrue);
            if (changed || btnPress) {
                m_NbMapUidsToRequest = m_NbMapUidsToRequest.Trim();
                int nbMaxUids = 25;
                // if this returns false we just use 25.
                if (m_NbMapUidsToRequest.Length > 0 && Text::TryParseInt(m_NbMapUidsToRequest, nbMaxUids, 10)) {
                    listUids.MapList_Request_Larger(nbMaxUids);
                } else {
                    listUids.MapList_Request();
                }
            }

            UI::EndDisabled();
            UI::Text("MapList_IsInProgress: " + listUids.MapList_IsInProgress);
            UI::Text("MsSinceLastReqStart: " + Time::Format(listUids.MsSinceLastReqStart));
            UI::Text("MsSinceLastReqEnd: " + Time::Format(listUids.MsSinceLastReqEnd));
            UI::Text("UpdateCount: " + listUids.UpdateCount);
            UI::Text("Slice Start / End / NbMaps: " + listUids.Slice_StartIx + " / " + listUids.Slice_EndIx + " / " + listUids.Slice_NbMaps);
            UI::Text("MapOrigIxInList: " + listUids.MapOrigIxInList + " (uid: " + listUids.MapOrigIxInListUid + ")");
            UI::Separator();
            UI::Text("UIDs & Names (" + listUids.MapList_MapUids.Length + "):");

            if (UI::BeginTable("##uids", 2, UI::TableFlags::SizingStretchSame)) {
                UI::TableSetupColumn("UIDs");
                UI::TableSetupColumn("Names");
                UI::TableHeadersRow();
                UI::ListClipper c(listUids.MapList_MapUids.Length);
                while (c.Step()) {
                    for (int i = c.DisplayStart; i < c.DisplayEnd; i++) {
                        UI::TableNextRow();
                        UI::TableNextColumn();
                        UI::Text(listUids.MapList_MapUids[i]);
                        UI::TableNextColumn();
                        UI::Text(Text::OpenplanetFormatCodes(listUids.MapList_Names[i]));
                    }
                }
                UI::EndTable();
            }
        }
        UI::End();

    }

    void RenderMenu() {
        if (UI::MenuItem("ListUids Demo", "", windowOpen)) {
            windowOpen = !windowOpen;
        }
    }
}
