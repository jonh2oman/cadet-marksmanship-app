import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/biathlon_coach_state.dart';
import '../domain/biathlon_race_type.dart';

class BiathlonCoachController extends Notifier<BiathlonCoachState> {
  final _uuid = const Uuid();
  static const _storageKey = 'biathlon_coach_state_v3';

  @override
  BiathlonCoachState build() {
    _loadState();
    return BiathlonCoachState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null) {
      try {
        final decoded = jsonDecode(data);
        state = BiathlonCoachState.fromJson(decoded as Map<String, dynamic>);
      } catch (e) {
        // Silently fail if data is corrupted
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.toJson());
    await prefs.setString(_storageKey, data);
  }

  void startMasterClock() {
    state = state.copyWith(masterStartTime: DateTime.now());
    _saveState();
  }

  void setMode(BiathlonMode mode) {
    state = state.copyWith(mode: mode);
    _saveState();
  }

  void resetMasterClock() async {
    state = BiathlonCoachState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  void addCompetitor(String name, String bib, BiathlonRaceType raceType, {int? lapCount, List<ShootingPosition>? customBouts}) {
    final sequence = customBouts ?? raceType.boutSequence;
    final shoots = sequence.map((pos) => ShootingRecord(position: pos)).toList();
    
    final newCompetitor = RaceCompetitor(
      id: _uuid.v4(),
      name: name,
      bib: bib,
      raceType: raceType,
      lapCount: lapCount,
      shoots: shoots,
    );

    state = state.copyWith(
      competitors: [...state.competitors, newCompetitor],
    );
    _saveState();
  }

  void removeCompetitor(String id) {
    state = state.copyWith(
      competitors: state.competitors.where((c) => c.id != id).toList(),
    );
    _saveState();
  }

  void startRace(String competitorId, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          return c.copyWith(
            status: CompetitorStatus.racing,
            raceStartTime: currentTime,
            laps: [LapRecord(index: 1, startTime: Duration.zero)],
          );
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void markLapEnd(String competitorId, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final elapsed = currentTime - (c.raceStartTime ?? currentTime);
          final currentLaps = List<LapRecord>.from(c.laps);
          if (currentLaps.isNotEmpty) {
            final lastIdx = currentLaps.length - 1;
            currentLaps[lastIdx] = currentLaps[lastIdx].copyWith(endTime: elapsed);
          }
          return c.copyWith(laps: currentLaps);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void markShootStart(String competitorId, int shootIdx, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final elapsed = currentTime - (c.raceStartTime ?? currentTime);
          final currentShoots = List<ShootingRecord>.from(c.shoots);
          currentShoots[shootIdx] = currentShoots[shootIdx].copyWith(startTime: elapsed);
          return c.copyWith(shoots: currentShoots);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void markShootEnd(String competitorId, int shootIdx, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final elapsed = currentTime - (c.raceStartTime ?? currentTime);
          final currentShoots = List<ShootingRecord>.from(c.shoots);
          currentShoots[shootIdx] = currentShoots[shootIdx].copyWith(endTime: elapsed);
          return c.copyWith(shoots: currentShoots);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void markLapStart(String competitorId, int lapIdx, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final elapsed = currentTime - (c.raceStartTime ?? currentTime);
          final currentLaps = List<LapRecord>.from(c.laps);
          if (currentLaps.length < lapIdx + 1) {
            currentLaps.add(LapRecord(index: lapIdx + 1, startTime: elapsed));
          }
          return c.copyWith(laps: currentLaps);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void finishRace(String competitorId, Duration currentTime) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final elapsed = currentTime - (c.raceStartTime ?? currentTime);
          final currentLaps = List<LapRecord>.from(c.laps);
          if (currentLaps.isNotEmpty) {
            final lastIdx = currentLaps.length - 1;
            currentLaps[lastIdx] = currentLaps[lastIdx].copyWith(endTime: elapsed);
          }
          return c.copyWith(status: CompetitorStatus.finished, laps: currentLaps);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }

  void toggleShot(String competitorId, int shootIndex, int shotIndex, bool hit) {
    state = state.copyWith(
      competitors: state.competitors.map((c) {
        if (c.id == competitorId) {
          final currentShoots = List<ShootingRecord>.from(c.shoots);
          final shoot = currentShoots[shootIndex];
          final newShots = List<bool?>.from(shoot.shots);
          
          if (newShots[shotIndex] == hit) {
            newShots[shotIndex] = null;
          } else {
            newShots[shotIndex] = hit;
          }

          currentShoots[shootIndex] = shoot.copyWith(shots: newShots);
          return c.copyWith(shoots: currentShoots);
        }
        return c;
      }).toList(),
    );
    _saveState();
  }
}

final biathlonCoachProvider = NotifierProvider<BiathlonCoachController, BiathlonCoachState>(
  BiathlonCoachController.new,
);

final masterClockProvider = StreamProvider<Duration>((ref) {
  final coachState = ref.watch(biathlonCoachProvider);
  if (!coachState.isRaceStarted) return Stream.value(Duration.zero);

  return Stream.periodic(const Duration(milliseconds: 100), (_) {
    final start = ref.read(biathlonCoachProvider).masterStartTime;
    if (start == null) return Duration.zero;
    return DateTime.now().difference(start);
  });
});
