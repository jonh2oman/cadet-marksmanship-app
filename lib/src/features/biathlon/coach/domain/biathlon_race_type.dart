enum ShootingPosition { prone, standing }

enum BiathlonRaceType {
  sprint,
  individual,
  massStart,
  pursuit,
  shortSprint,
  custom,
}

extension BiathlonRaceTypeX on BiathlonRaceType {
  String get displayName {
    switch (this) {
      case BiathlonRaceType.sprint: return 'Sprint';
      case BiathlonRaceType.individual: return 'Individual';
      case BiathlonRaceType.massStart: return 'Mass Start';
      case BiathlonRaceType.pursuit: return 'Pursuit';
      case BiathlonRaceType.shortSprint: return 'Short Sprint';
      case BiathlonRaceType.custom: return 'Custom';
    }
  }

  int get lapCount {
    switch (this) {
      case BiathlonRaceType.sprint: return 3;
      case BiathlonRaceType.individual: return 5;
      case BiathlonRaceType.massStart: return 5;
      case BiathlonRaceType.pursuit: return 5;
      case BiathlonRaceType.shortSprint: return 3;
      case BiathlonRaceType.custom: return 3; // Default
    }
  }

  List<ShootingPosition> get boutSequence {
    switch (this) {
      case BiathlonRaceType.sprint: 
        return [ShootingPosition.prone, ShootingPosition.standing];
      case BiathlonRaceType.individual: 
        return [ShootingPosition.prone, ShootingPosition.standing, ShootingPosition.prone, ShootingPosition.standing];
      case BiathlonRaceType.massStart:
      case BiathlonRaceType.pursuit:
        return [ShootingPosition.prone, ShootingPosition.prone, ShootingPosition.standing, ShootingPosition.standing];
      case BiathlonRaceType.shortSprint:
        return [ShootingPosition.prone, ShootingPosition.standing];
      case BiathlonRaceType.custom:
        return []; // To be defined by user
    }
  }

  String get description {
    switch (this) {
      case BiathlonRaceType.sprint: 
        return '3 Laps | 2 Bouts (Prone, Standing)';
      case BiathlonRaceType.individual: 
        return '5 Laps | 4 Bouts (P, S, P, S)';
      case BiathlonRaceType.massStart:
        return '5 Laps | 4 Bouts (P, P, S, S)';
      case BiathlonRaceType.pursuit:
        return '5 Laps | 4 Bouts (P, P, S, S)';
      case BiathlonRaceType.shortSprint:
        return '3 Laps | 2 Bouts (P, S) - Accelerated';
      case BiathlonRaceType.custom:
        return 'User-defined laps and shooting sequence';
    }
  }

  int get penaltySecondsPerMiss {
    switch (this) {
      case BiathlonRaceType.individual: return 60;
      case BiathlonRaceType.custom: return 60; // Common for custom range practice
      default: return 0; // Sprint, Pursuit, etc. use penalty loops
    }
  }

  String toJson() => name;
  static BiathlonRaceType fromJson(String json) => BiathlonRaceType.values.byName(json);
}

extension ShootingPositionX on ShootingPosition {
  String toJson() => name;
  static ShootingPosition fromJson(String json) => ShootingPosition.values.byName(json);
}
