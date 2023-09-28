// can be removed after this update is live

string ProcessRaceStats2023_Oct(const string &in scriptIn) {
    // if we are running a version prior to 2023-09-29, then we use the path (which means doing nothing atm)
    //   `Libs/Nadeo/TMNext/TrackMania/Modes/COTDQualifications`
    // otherwise we use
    //   `Libs/Nadeo/Trackmania/Modes/COTDQualifications`

    // 2023-09-19_19_09
    auto ver = GetApp().SystemPlatform.ExeVersion;
    auto yyyy_mm = ver.SubStr(0, 7);
    auto dd = Text::ParseInt(ver.SubStr(8, 2));

    // print('yyyy_mm: ' + yyyy_mm);
    // print('dd: ' + dd);

    // print("('2023-09' < '2023-10'): " + ('2023-09' < '2023-10'));
    // print("(yyyy_mm < '2023-10'): " + (yyyy_mm < '2023-10'));

    if (yyyy_mm < '2023-09') return scriptIn;
    if (yyyy_mm == '2023-09' && dd <= 19) return scriptIn;

    return scriptIn.Replace("Libs/Nadeo/TMNext/TrackMania/Modes/COTDQualifications", "Libs/Nadeo/Trackmania/Modes/COTDQualifications");
}
