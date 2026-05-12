import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/biathlon_rules.dart';
import '../../../data/marksmanship_rules.dart';

class RulebookScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> rules;
  
  const RulebookScreen({
    super.key, 
    required this.title,
    required this.rules,
  });

  @override
  State<RulebookScreen> createState() => _RulebookScreenState();
}

class _RulebookScreenState extends State<RulebookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedTag = 'All';

  static const List<String> _tags = [
    'All', 'General', 'Eligibility', 'Teams', 'Race Rules',
    'Shooting', 'Coaching', 'Penalties', 'Course', 'Range', 'Safety', 'Administration',
  ];

  static const Map<String, IconData> _tagIcons = {
    'General':        LucideIcons.info,
    'Eligibility':    LucideIcons.userCheck,
    'Teams':          LucideIcons.users,
    'Race Rules':     LucideIcons.flag,
    'Shooting':       LucideIcons.target,
    'Coaching':       LucideIcons.clipboard,
    'Penalties':      LucideIcons.alertTriangle,
    'Course':         LucideIcons.mapPin,
    'Range':          LucideIcons.crosshair,
    'Safety':         LucideIcons.shieldCheck,
    'Administration': LucideIcons.fileText,
  };

  List<Map<String, dynamic>> get _filtered {
    return widget.rules.where((r) {
      final matchesTag = _selectedTag == 'All' || r['tag'] == _selectedTag;
      if (!matchesTag) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (r['title'] as String).toLowerCase().contains(q) ||
          (r['content'] as String).toLowerCase().contains(q) ||
          (r['section'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white38),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search rules, procedures...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.white54),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _tags.length,
                itemBuilder: (ctx, i) {
                  final tag = _tags[i];
                  final selected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(tag, style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.black : Colors.white70,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedTag = tag),
                      selectedColor: const Color(0xFF38BDF8),
                      backgroundColor: const Color(0xFF1E293B),
                      showCheckmark: false,
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.searchX, size: 48, color: Colors.white24),
                          const SizedBox(height: 12),
                          Text('No rules found', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Try a different search term', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) => _RuleCard(rule: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatefulWidget {
  final Map<String, dynamic> rule;
  const _RuleCard({required this.rule});

  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  bool _expanded = false;

  static const Map<String, Color> _tagColors = {
    'Penalties':      Color(0xFFEF4444),
    'Safety':         Color(0xFFF59E0B),
    'Shooting':       Color(0xFF38BDF8),
    'Range':          Color(0xFF8B5CF6),
    'Coaching':       Color(0xFF10B981),
    'Race Rules':     Color(0xFF3B82F6),
    'Eligibility':    Color(0xFF6366F1),
    'Teams':          Color(0xFF14B8A6),
    'Course':         Color(0xFF84CC16),
    'Administration': Color(0xFF94A3B8),
    'General':        Color(0xFF94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = widget.rule['tag'] as String;
    final color = _tagColors[tag] ?? Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rule['section'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.rule['title'] as String,
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    color: Colors.white38,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),
                    Text(
                      widget.rule['content'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
