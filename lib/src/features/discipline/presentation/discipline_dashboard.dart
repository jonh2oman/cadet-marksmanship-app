import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../rulebook/presentation/rulebook_screen.dart';
import '../../scoring/presentation/scoring_screen.dart';
import '../../biathlon/coach/presentation/biathlon_coach_screen.dart';
import '../../../data/biathlon_rules.dart';
import '../../../data/marksmanship_rules.dart';

class DisciplineDashboard extends StatefulWidget {
  final String title;
  final Color primaryColor;

  const DisciplineDashboard({
    super.key,
    required this.title,
    required this.primaryColor,
  });

  @override
  State<DisciplineDashboard> createState() => _DisciplineDashboardState();
}

class _DisciplineDashboardState extends State<DisciplineDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isBiathlon = widget.title.toLowerCase() == 'biathlon';
    final rules = isBiathlon ? biathlonRules : marksmanshipRules;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          RulebookScreen(title: widget.title, rules: rules),
          if (isBiathlon)
            const BiathlonCoachScreen()
          else
            ScoringScreen(title: widget.title),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(LucideIcons.book),
            label: 'Rulebook',
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.target),
            label: isBiathlon ? 'Coach a race!' : 'Scoring',
          ),
        ],
      ),
    );
  }
}
