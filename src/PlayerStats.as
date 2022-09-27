#if DEV
shared class PlayerStats {
  /* Properties // Mixin: Default Properties */
  private string _Name;
  private uint _TimeNow;
  private string _SpawnStatus;
  private array<uint> _CurrentLapTimes;
  private array<uint> _CurrentRaceTimes;
  private uint _CurrentLapTime;
  private uint _CurrentRaceTime;

  /* Methods // Mixin: Default Constructor */
  PlayerStats(const string &in Name, uint TimeNow, const string &in SpawnStatus, const uint[] &in CurrentLapTimes, const uint[] &in CurrentRaceTimes, uint CurrentLapTime, uint CurrentRaceTime) {
    this._Name = Name;
    this._TimeNow = TimeNow;
    this._SpawnStatus = SpawnStatus;
    this._CurrentLapTimes = CurrentLapTimes;
    this._CurrentRaceTimes = CurrentRaceTimes;
    this._CurrentLapTime = CurrentLapTime;
    this._CurrentRaceTime = CurrentRaceTime;
  }

  /* Methods // Mixin: ToFrom JSON Object */
  PlayerStats(const Json::Value &in j) {
    try {
      this._Name = string(j["Name"]);
      this._SpawnStatus = string(j["SpawnStatus"]);
      this._CurrentLapTimes = array<uint>(j["CurrentLapTimes"].Length);
      for (uint i = 0; i < j["CurrentLapTimes"].Length; i++) {
        this._CurrentLapTimes[i] = uint(j["CurrentLapTimes"][i]);
      }
      this._CurrentRaceTimes = array<uint>(j["CurrentRaceTimes"].Length);
      for (uint i = 0; i < j["CurrentRaceTimes"].Length; i++) {
        this._CurrentRaceTimes[i] = uint(j["CurrentRaceTimes"][i]);
      }
      this._CurrentLapTime = uint(j["CurrentLapTime"]);
      this._CurrentRaceTime = uint(j["CurrentRaceTime"]);
    } catch {
      OnFromJsonError(j);
    }
  }

  Json::Value ToJson() {
    Json::Value j = Json::Object();
    j["Name"] = _Name;
    j["TimeNow"] = _TimeNow;
    j["SpawnStatus"] = _SpawnStatus;
    Json::Value _tmp_CurrentLapTimes = Json::Array();
    for (uint i = 0; i < _CurrentLapTimes.Length; i++) {
      auto v = _CurrentLapTimes[i];
      _tmp_CurrentLapTimes.Add(Json::Value(v));
    }
    j["CurrentLapTimes"] = _tmp_CurrentLapTimes;
    Json::Value _tmp_CurrentRaceTimes = Json::Array();
    for (uint i = 0; i < _CurrentRaceTimes.Length; i++) {
      auto v = _CurrentRaceTimes[i];
      _tmp_CurrentRaceTimes.Add(Json::Value(v));
    }
    j["CurrentRaceTimes"] = _tmp_CurrentRaceTimes;
    j["CurrentLapTime"] = _CurrentLapTime;
    j["CurrentRaceTime"] = _CurrentRaceTime;
    return j;
  }

  void OnFromJsonError(const Json::Value &in j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }

  /* Methods // Mixin: Getters */
  const string get_Name() const {
    return this._Name;
  }

  uint get_TimeNow() const {
    return this._TimeNow;
  }

  const string get_SpawnStatus() const {
    return this._SpawnStatus;
  }

  const uint[]@ get_CurrentLapTimes() const {
    return this._CurrentLapTimes;
  }

  const uint[]@ get_CurrentRaceTimes() const {
    return this._CurrentRaceTimes;
  }

  uint get_CurrentLapTime() const {
    return this._CurrentLapTime;
  }

  uint get_CurrentRaceTime() const {
    return this._CurrentRaceTime;
  }

  /* Methods // Mixin: Setters */
  void set_Name(const string &in new_Name) {
    this._Name = new_Name;
  }

  void set_TimeNow(uint new_TimeNow) {
    this._TimeNow = new_TimeNow;
  }

  void set_SpawnStatus(const string &in new_SpawnStatus) {
    this._SpawnStatus = new_SpawnStatus;
  }

  void set_CurrentLapTimes(const uint[] &in new_CurrentLapTimes) {
    this._CurrentLapTimes = new_CurrentLapTimes;
  }

  void set_CurrentRaceTimes(const uint[] &in new_CurrentRaceTimes) {
    this._CurrentRaceTimes = new_CurrentRaceTimes;
  }

  void set_CurrentLapTime(uint new_CurrentLapTime) {
    this._CurrentLapTime = new_CurrentLapTime;
  }

  void set_CurrentRaceTime(uint new_CurrentRaceTime) {
    this._CurrentRaceTime = new_CurrentRaceTime;
  }

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'PlayerStats('
      + string::Join({'Name=' + Name, 'TimeNow=' + '' + TimeNow, 'SpawnStatus=' + SpawnStatus, 'CurrentLapTimes=' + TS_Array_uint(CurrentLapTimes), 'CurrentRaceTimes=' + TS_Array_uint(CurrentRaceTimes), 'CurrentLapTime=' + '' + CurrentLapTime, 'CurrentRaceTime=' + '' + CurrentRaceTime}, ', ')
      + ')';
  }

  private const string TS_Array_uint(const array<uint> &in arr) {
    string ret = '{';
    for (uint i = 0; i < arr.Length; i++) {
      if (i > 0) ret += ', ';
      ret += '' + arr[i];
    }
    return ret + '}';
  }

  /* Methods // Mixin: Op Eq */
  bool opEquals(const PlayerStats@ &in other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    bool _tmp_arrEq_CurrentLapTimes = _CurrentLapTimes.Length == other.CurrentLapTimes.Length;
    for (uint i = 0; i < _CurrentLapTimes.Length; i++) {
      if (!_tmp_arrEq_CurrentLapTimes) {
        break;
      }
      _tmp_arrEq_CurrentLapTimes = _tmp_arrEq_CurrentLapTimes && (_CurrentLapTimes[i] == other.CurrentLapTimes[i]);
    }
    bool _tmp_arrEq_CurrentRaceTimes = _CurrentRaceTimes.Length == other.CurrentRaceTimes.Length;
    for (uint i = 0; i < _CurrentRaceTimes.Length; i++) {
      if (!_tmp_arrEq_CurrentRaceTimes) {
        break;
      }
      _tmp_arrEq_CurrentRaceTimes = _tmp_arrEq_CurrentRaceTimes && (_CurrentRaceTimes[i] == other.CurrentRaceTimes[i]);
    }
    return true
      && _Name == other.Name
      && _TimeNow == other.TimeNow
      && _SpawnStatus == other.SpawnStatus
      && _tmp_arrEq_CurrentLapTimes
      && _tmp_arrEq_CurrentRaceTimes
      && _CurrentLapTime == other.CurrentLapTime
      && _CurrentRaceTime == other.CurrentRaceTime
      ;
  }
}
#endif
