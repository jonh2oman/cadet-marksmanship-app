import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum CompetitorLevel { junior, senior }

class Competitor {
  final String id;
  final String name;
  final String rank;
  final DateTime dob;

  Competitor({
    required this.id,
    required this.name,
    required this.rank,
    required this.dob,
  });

  int get age {
    final now = DateTime.now();
    // Rule: Age as of Jan 1st of the current year
    final Jan1 = DateTime(now.year, 1, 1);
    int age = Jan1.year - dob.year;
    if (Jan1.month < dob.month || (Jan1.month == dob.month && Jan1.day < dob.day)) {
      age--;
    }
    return age;
  }

  CompetitorLevel get level => age < 15 ? CompetitorLevel.junior : CompetitorLevel.senior;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'dob': dob.toIso8601String(),
  };

  factory Competitor.fromJson(Map<String, dynamic> json) => Competitor(
    id: json['id'],
    name: json['name'],
    rank: json['rank'],
    dob: DateTime.parse(json['dob']),
  );
}

class Team {
  final String id;
  final String name;
  final List<Competitor> members;

  Team({
    required this.id,
    required this.name,
    required this.members,
  });

  int get juniorCount => members.where((m) => m.level == CompetitorLevel.junior).length;
  bool get isValid => members.length == 5 && juniorCount >= 2;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members.map((m) => m.toJson()).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    members: (json['members'] as List).map((m) => Competitor.fromJson(m)).toList(),
  );

  Team copyWith({String? name, List<Competitor>? members}) {
    return Team(
      id: id,
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }
}

class TeamController extends Notifier<List<Team>> {
  static const _storageKey = 'marksmanship_teams_v1';
  final _uuid = const Uuid();

  @override
  List<Team> build() {
    _loadState();
    return [];
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      state = decoded.map((t) => Team.fromJson(t)).toList();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void addTeam(String name) {
    state = [...state, Team(id: _uuid.v4(), name: name, members: [])];
    _saveState();
  }

  void removeTeam(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveState();
  }

  void updateTeam(Team updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    _saveState();
  }
}

final teamProvider = NotifierProvider<TeamController, List<Team>>(TeamController.new);
