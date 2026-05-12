enum TargetType { grouping, competition }

class FiringPoint {
  final int laneNumber;
  final String? competitorName;
  final String? teamName;
  final TargetType targetType;
  final int? score;
  final int? innerTens;
  final double? groupingMm;

  FiringPoint({
    required this.laneNumber,
    this.competitorName,
    this.teamName,
    required this.targetType,
    this.score,
    this.innerTens,
    this.groupingMm,
  });

  FiringPoint copyWith({
    String? competitorName,
    String? teamName,
    TargetType? targetType,
    int? score,
    int? innerTens,
    double? groupingMm,
  }) {
    return FiringPoint(
      laneNumber: laneNumber,
      competitorName: competitorName ?? this.competitorName,
      teamName: teamName ?? this.teamName,
      targetType: targetType ?? this.targetType,
      score: score ?? this.score,
      innerTens: innerTens ?? this.innerTens,
      groupingMm: groupingMm ?? this.groupingMm,
    );
  }

  Map<String, dynamic> toJson() => {
    'laneNumber': laneNumber,
    'competitorName': competitorName,
    'teamName': teamName,
    'targetType': targetType.name,
    'score': score,
    'innerTens': innerTens,
    'groupingMm': groupingMm,
  };

  factory FiringPoint.fromJson(Map<String, dynamic> json) => FiringPoint(
    laneNumber: json['laneNumber'] as int,
    competitorName: json['competitorName'] as String?,
    teamName: json['teamName'] as String?,
    targetType: TargetType.values.byName(json['targetType'] as String),
    score: json['score'] as int?,
    innerTens: json['innerTens'] as int?,
    groupingMm: json['groupingMm'] as double?,
  );
}

class Relay {
  final String id;
  final int number;
  final List<FiringPoint> firingPoints;
  final bool isActive;
  final String? relayType; // 'individual' or 'team'
  final String? teamId;

  Relay({
    required this.id,
    required this.number,
    required this.firingPoints,
    this.isActive = false,
    this.relayType,
    this.teamId,
  });

  Relay copyWith({
    List<FiringPoint>? firingPoints,
    bool? isActive,
    String? relayType,
    String? teamId,
  }) {
    return Relay(
      id: id,
      number: number,
      firingPoints: firingPoints ?? this.firingPoints,
      isActive: isActive ?? this.isActive,
      relayType: relayType ?? this.relayType,
      teamId: teamId ?? this.teamId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'firingPoints': firingPoints.map((f) => f.toJson()).toList(),
    'isActive': isActive,
    'relayType': relayType,
    'teamId': teamId,
  };

  factory Relay.fromJson(Map<String, dynamic> json) => Relay(
    id: json['id'] as String,
    number: json['number'] as int,
    firingPoints: (json['firingPoints'] as List).map((f) => FiringPoint.fromJson(f as Map<String, dynamic>)).toList(),
    isActive: json['isActive'] as bool,
    relayType: json['relayType'] as String?,
    teamId: json['teamId'] as String?,
  );
}
