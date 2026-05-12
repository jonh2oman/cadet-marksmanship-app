import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/relay_state.dart';

class RelayController extends Notifier<List<Relay>> {
  final _uuid = const Uuid();
  static const _storageKey = 'marksmanship_relays_v1';

  @override
  List<Relay> build() {
    _loadState();
    return [];
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      try {
        final decoded = jsonDecode(data) as List;
        state = decoded.map((r) => Relay.fromJson(r as Map<String, dynamic>)).toList();
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void addRelay(int laneCount, String type) {
    final number = state.length + 1;
    final List<FiringPoint> firingPoints = List.generate(
      laneCount, 
      (i) => FiringPoint(
        laneNumber: i + 1,
        targetType: TargetType.competition,
      ),
    );

    state = [
      ...state,
      Relay(
        id: _uuid.v4(),
        number: number,
        firingPoints: firingPoints,
        relayType: type,
      ),
    ];
    _saveState();
  }

  void removeRelay(String id) {
    state = state.where((r) => r.id != id).toList();
    _saveState();
  }

  void updateFiringPoint(String relayId, int laneNumber, FiringPoint updated) {
    state = state.map((r) {
      if (r.id == relayId) {
        final points = r.firingPoints.map((f) {
          return f.laneNumber == laneNumber ? updated : f;
        }).toList();
        return r.copyWith(firingPoints: points);
      }
      return r;
    }).toList();
    _saveState();
  }

  void toggleRelayActive(String id) {
    state = state.map((r) {
      if (r.id == id) return r.copyWith(isActive: !r.isActive);
      return r;
    }).toList();
    _saveState();
  }

  void saveCompetitionScore(String relayId, int laneNumber, int score, int innerTens) {
    state = state.map((r) {
      if (r.id == relayId) {
        final points = r.firingPoints.map((f) {
          if (f.laneNumber == laneNumber) {
            return f.copyWith(score: score, innerTens: innerTens);
          }
          return f;
        }).toList();
        return r.copyWith(firingPoints: points);
      }
      return r;
    }).toList();
    _saveState();
  }

  void saveGroupingScore(String relayId, int laneNumber, double groupingMm) {
    state = state.map((r) {
      if (r.id == relayId) {
        final points = r.firingPoints.map((f) {
          if (f.laneNumber == laneNumber) {
            return f.copyWith(groupingMm: groupingMm);
          }
          return f;
        }).toList();
        return r.copyWith(firingPoints: points);
      }
      return r;
    }).toList();
    _saveState();
  }

  void updateRelay(Relay updated) {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
    _saveState();
  }

  void setRelayTeam(String relayId, String? teamId) {
    state = state.map((r) {
      if (r.id == relayId) return r.copyWith(teamId: teamId);
      return r;
    }).toList();
    _saveState();
  }
}

final relayProvider = NotifierProvider<RelayController, List<Relay>>(
  RelayController.new,
);
