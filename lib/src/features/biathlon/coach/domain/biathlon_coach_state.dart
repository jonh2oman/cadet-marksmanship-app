import 'biathlon_race_type.dart';

enum BiathlonMode { ski, run }

class ShootingRecord {
  final ShootingPosition position;
  final List<bool?> shots; // null = not fired, true = hit, false = miss
  final Duration? startTime;
  final Duration? endTime;

  ShootingRecord({
    required this.position,
    List<bool?>? shots,
    this.startTime,
    this.endTime,
  }) : shots = shots ?? List.filled(5, null);

  int get hits => shots.where((s) => s == true).length;
  int get misses => shots.where((s) => s == false).length;
  bool get isComplete => shots.every((s) => s != null);

  Duration? get duration => (startTime != null && endTime != null) ? endTime! - startTime! : null;

  ShootingRecord copyWith({
    List<bool?>? shots,
    Duration? startTime,
    Duration? endTime,
  }) {
    return ShootingRecord(
      position: position,
      shots: shots ?? this.shots,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'position': position.toJson(),
    'shots': shots,
    'startTime': startTime?.inMilliseconds,
    'endTime': endTime?.inMilliseconds,
  };

  factory ShootingRecord.fromJson(Map<String, dynamic> json) => ShootingRecord(
    position: ShootingPositionX.fromJson(json['position'] as String),
    shots: (json['shots'] as List).cast<bool?>(),
    startTime: json['startTime'] != null ? Duration(milliseconds: json['startTime'] as int) : null,
    endTime: json['endTime'] != null ? Duration(milliseconds: json['endTime'] as int) : null,
  );
}

class LapRecord {
  final int index;
  final Duration startTime;
  final Duration? endTime;

  LapRecord({
    required this.index,
    required this.startTime,
    this.endTime,
  });

  Duration? get duration => endTime != null ? endTime! - startTime : null;

  LapRecord copyWith({Duration? endTime}) {
    return LapRecord(
      index: index,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'startTime': startTime.inMilliseconds,
    'endTime': endTime?.inMilliseconds,
  };

  factory LapRecord.fromJson(Map<String, dynamic> json) => LapRecord(
    index: json['index'] as int,
    startTime: Duration(milliseconds: json['startTime'] as int),
    endTime: json['endTime'] != null ? Duration(milliseconds: json['endTime'] as int) : null,
  );
}

enum CompetitorStatus { ready, racing, finished }

class RaceCompetitor {
  final String id;
  final String name;
  final String bib;
  final BiathlonRaceType raceType;
  final int lapCount;
  final CompetitorStatus status;
  final Duration? raceStartTime;
  final List<LapRecord> laps;
  final List<ShootingRecord> shoots;

  RaceCompetitor({
    required this.id,
    required this.name,
    required this.bib,
    required this.raceType,
    int? lapCount,
    this.status = CompetitorStatus.ready,
    this.raceStartTime,
    this.laps = const [],
    this.shoots = const [],
  }) : lapCount = lapCount ?? raceType.lapCount;

  int get currentLapIndex => laps.length;
  int get currentShootIndex => shoots.indexWhere((s) => !s.isComplete);
  
  int get totalMisses => shoots.fold(0, (sum, s) => sum + s.misses);
  Duration get totalPenaltyTime => Duration(seconds: totalMisses * raceType.penaltySecondsPerMiss);

  Duration getAdjustedTime(Duration elapsed) {
    return elapsed + totalPenaltyTime;
  }

  RaceCompetitor copyWith({
    CompetitorStatus? status,
    Duration? raceStartTime,
    List<LapRecord>? laps,
    List<ShootingRecord>? shoots,
    int? lapCount,
  }) {
    return RaceCompetitor(
      id: id,
      name: name,
      bib: bib,
      raceType: raceType,
      lapCount: lapCount ?? this.lapCount,
      status: status ?? this.status,
      raceStartTime: raceStartTime ?? this.raceStartTime,
      laps: laps ?? this.laps,
      shoots: shoots ?? this.shoots,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bib': bib,
    'raceType': raceType.toJson(),
    'lapCount': lapCount,
    'status': status.name,
    'raceStartTime': raceStartTime?.inMilliseconds,
    'laps': laps.map((l) => l.toJson()).toList(),
    'shoots': shoots.map((s) => s.toJson()).toList(),
  };

  factory RaceCompetitor.fromJson(Map<String, dynamic> json) => RaceCompetitor(
    id: json['id'] as String,
    name: json['name'] as String,
    bib: json['bib'] as String,
    raceType: BiathlonRaceTypeX.fromJson(json['raceType'] as String),
    lapCount: json['lapCount'] as int? ?? BiathlonRaceTypeX.fromJson(json['raceType'] as String).lapCount,
    status: CompetitorStatus.values.byName(json['status'] as String),
    raceStartTime: json['raceStartTime'] != null ? Duration(milliseconds: json['raceStartTime'] as int) : null,
    laps: (json['laps'] as List).map((l) => LapRecord.fromJson(l as Map<String, dynamic>)).toList(),
    shoots: (json['shoots'] as List).map((s) => ShootingRecord.fromJson(s as Map<String, dynamic>)).toList(),
  );
}

class BiathlonCoachState {
  final List<RaceCompetitor> competitors;
  final DateTime? masterStartTime;
  final BiathlonMode mode;

  BiathlonCoachState({
    this.competitors = const [],
    this.masterStartTime,
    this.mode = BiathlonMode.ski,
  });

  bool get isRaceStarted => masterStartTime != null;

  BiathlonCoachState copyWith({
    List<RaceCompetitor>? competitors,
    DateTime? masterStartTime,
    BiathlonMode? mode,
  }) {
    return BiathlonCoachState(
      competitors: competitors ?? this.competitors,
      masterStartTime: masterStartTime ?? this.masterStartTime,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() => {
    'competitors': competitors.map((c) => c.toJson()).toList(),
    'masterStartTime': masterStartTime?.millisecondsSinceEpoch,
    'mode': mode.name,
  };

  factory BiathlonCoachState.fromJson(Map<String, dynamic> json) => BiathlonCoachState(
    competitors: (json['competitors'] as List).map((c) => RaceCompetitor.fromJson(c as Map<String, dynamic>)).toList(),
    masterStartTime: json['masterStartTime'] != null ? DateTime.fromMillisecondsSinceEpoch(json['masterStartTime'] as int) : null,
    mode: BiathlonMode.values.byName(json['mode'] as String? ?? 'ski'),
  );
}
