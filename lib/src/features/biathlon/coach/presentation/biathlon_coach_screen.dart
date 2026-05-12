import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/biathlon_coach_controller.dart';
import '../domain/biathlon_coach_state.dart';
import '../domain/biathlon_race_type.dart';

class BiathlonCoachScreen extends ConsumerWidget {
  const BiathlonCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(biathlonCoachProvider);
    final competitors = coachState.competitors;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _CoachHeader(onAdd: () => _showAddCompetitorDialog(context, ref)),
            Expanded(
              child: competitors.isEmpty
                  ? _EmptyState(onAdd: () => _showAddCompetitorDialog(context, ref))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: competitors.length,
                      itemBuilder: (ctx, i) => _CompetitorCard(competitor: competitors[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCompetitorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddCompetitorDialog(),
    );
  }
}

class _CoachHeader extends ConsumerWidget {
  final VoidCallback onAdd;
  const _CoachHeader({required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(masterClockProvider).value ?? Duration.zero;
    final coachState = ref.watch(biathlonCoachProvider);
    final isStarted = coachState.isRaceStarted;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white54),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStarted ? 'RACE IN PROGRESS' : 'RACE READY', 
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isStarted ? const Color(0xFF10B981) : const Color(0xFF38BDF8), 
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(clock), 
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.white)
                ),
              ],
            ),
          ),
          if (isStarted)
            IconButton(
              onPressed: () => ref.read(biathlonCoachProvider.notifier).resetMasterClock(),
              icon: const Icon(LucideIcons.rotateCcw, color: Colors.white38),
              tooltip: 'Reset Race',
            ),
          const SizedBox(width: 8),
          if (!isStarted)
            ElevatedButton.icon(
              onPressed: () => ref.read(biathlonCoachProvider.notifier).startMasterClock(),
              icon: const Icon(LucideIcons.play, size: 18),
              label: const Text('START RACE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          if (isStarted) const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.userPlus, size: 18),
            label: const Text('ADD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitorCard extends ConsumerWidget {
  final RaceCompetitor competitor;
  const _CompetitorCard({required this.competitor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(biathlonCoachProvider);
    final clock = ref.watch(masterClockProvider).value ?? Duration.zero;
    final theme = Theme.of(context);
    final isMasterStarted = coachState.isRaceStarted;
    
    final elapsed = competitor.status == CompetitorStatus.racing
        ? clock - (competitor.raceStartTime ?? clock)
        : (competitor.status == CompetitorStatus.finished ? competitor.laps.last.endTime ?? Duration.zero : Duration.zero);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: competitor.status == CompetitorStatus.racing ? const Color(0xFF38BDF8).withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _BibNumber(bib: competitor.bib),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(competitor.name, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                      Text(competitor.raceType.displayName, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL TIME', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(
                      _formatDuration(competitor.getAdjustedTime(elapsed)), 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        fontFamily: 'monospace',
                        color: competitor.totalPenaltyTime > Duration.zero ? const Color(0xFFEF4444) : Colors.white,
                      )
                    ),
                    if (competitor.totalPenaltyTime > Duration.zero)
                      Text(
                        '${coachState.mode == BiathlonMode.ski ? 'SKI' : 'RUN'}: ${_formatDuration(elapsed)}', 
                        style: const TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => ref.read(biathlonCoachProvider.notifier).removeCompetitor(competitor.id),
                  icon: const Icon(LucideIcons.trash2, color: Colors.white24, size: 18),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
          if (competitor.status == CompetitorStatus.ready && isMasterStarted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(biathlonCoachProvider.notifier).startRace(competitor.id, clock),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('START TRACKING ATHLETE'),
                ),
              ),
            ),
          if (competitor.status == CompetitorStatus.ready && !isMasterStarted)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('WAITING FOR RACE START', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          if (competitor.status != CompetitorStatus.ready) ...[
            const Divider(height: 1, color: Colors.white10),
            _RaceSplits(competitor: competitor),
            const Divider(height: 1, color: Colors.white10),
            _ShootingProgress(competitor: competitor),
            const Divider(height: 1, color: Colors.white10),
            _RaceTimeline(competitor: competitor),
          ],
        ],
      ),
    );
  }
}

class _BibNumber extends StatelessWidget {
  final String bib;
  const _BibNumber({required this.bib});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(bib, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}

class _ShootingProgress extends ConsumerWidget {
  final RaceCompetitor competitor;
  const _ShootingProgress({required this.competitor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SHOOTING LOG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
              Text(
                'HITS: ${competitor.shoots.fold(0, (sum, s) => sum + s.hits)} | MISSES: ${competitor.totalMisses}', 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...competitor.shoots.asMap().entries.map((entry) {
            final idx = entry.key;
            final shoot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(shoot.position == ShootingPosition.prone ? 'P' : 'S', 
                        style: TextStyle(color: shoot.position == ShootingPosition.prone ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (shotIdx) {
                        final val = shoot.shots[shotIdx];
                        return GestureDetector(
                          onTap: () => ref.read(biathlonCoachProvider.notifier).toggleShot(competitor.id, idx, shotIdx, true),
                          onLongPress: () => ref.read(biathlonCoachProvider.notifier).toggleShot(competitor.id, idx, shotIdx, false),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                              color: val == true ? const Color(0xFF10B981) : (val == false ? const Color(0xFFEF4444) : Colors.transparent),
                            ),
                            child: val != null 
                              ? Icon(val ? LucideIcons.check : LucideIcons.x, size: 16, color: Colors.white)
                              : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RaceTimeline extends ConsumerWidget {
  final RaceCompetitor competitor;
  const _RaceTimeline({required this.competitor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(biathlonCoachProvider.notifier);
    final clock = ref.watch(masterClockProvider).value ?? Duration.zero;
    final isFinished = competitor.status == CompetitorStatus.finished;

    if (isFinished) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('RACE FINISHED', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
      );
    }

    // Determine current "Next Action"
    Widget? actionButton;
    String label = '';
    
    // Check Laps
    for (int i = 0; i < competitor.lapCount; i++) {
      final lap = i < competitor.laps.length ? competitor.laps[i] : null;
      
      if (lap == null) {
        // Need to start next lap (happens after shooting)
        label = 'LAP ${i + 1} START';
        actionButton = _buildButton(
          context, 
          label, 
          const Color(0xFF38BDF8), 
          () => notifier.markLapStart(competitor.id, i, clock)
        );
        break;
      } else if (lap.endTime == null) {
        // Current lap is running
        if (i < competitor.lapCount - 1) {
          label = 'LAP ${i + 1} END (ENTER RANGE)';
          actionButton = _buildButton(
            context, 
            label, 
            const Color(0xFFFACC15), 
            () => notifier.markLapEnd(competitor.id, clock)
          );
        } else {
          // Final Lap
          label = 'FINISH';
          actionButton = _buildButton(
            context, 
            label, 
            const Color(0xFF10B981), 
            () => notifier.finishRace(competitor.id, clock)
          );
        }
        break;
      }

      // Check Shooting for this lap (if not last lap)
      if (i < competitor.shoots.length) {
        final shoot = competitor.shoots[i];
        if (shoot.startTime == null) {
          label = 'SHOOT ${i + 1} START';
          actionButton = _buildButton(
            context, 
            label, 
            const Color(0xFFF472B6), 
            () => notifier.markShootStart(competitor.id, i, clock)
          );
          break;
        } else if (shoot.endTime == null) {
          label = 'SHOOT ${i + 1} FINISH';
          actionButton = _buildButton(
            context, 
            label, 
            const Color(0xFFA78BFA), 
            () => notifier.markShootEnd(competitor.id, i, clock)
          );
          break;
        }
      }
    }

    // Always show a calculation summary at the bottom of the timeline/card
    final elapsed = competitor.status == CompetitorStatus.racing
        ? clock - (competitor.raceStartTime ?? clock)
        : (competitor.status == CompetitorStatus.finished ? (competitor.laps.isEmpty ? Duration.zero : competitor.laps.last.endTime ?? Duration.zero) : Duration.zero);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: actionButton ?? const SizedBox(),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SummaryRow(
                label: ref.watch(biathlonCoachProvider).mode == BiathlonMode.ski ? 'RAW SKI TIME' : 'RAW RUN TIME',
                value: _formatDuration(elapsed),
              ),
              const SizedBox(height: 4),
              _SummaryRow(
                label: 'PENALTIES (${competitor.totalMisses} x ${competitor.raceType.penaltySecondsPerMiss}s)',
                value: '+ ${_formatDuration(competitor.totalPenaltyTime)}',
                color: const Color(0xFFEF4444),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Colors.white10),
              ),
              _SummaryRow(
                label: 'ADJUSTED TOTAL',
                value: _formatDuration(competitor.getAdjustedTime(elapsed)),
                isBold: true,
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }
}

class _AddCompetitorDialog extends StatefulWidget {
  const _AddCompetitorDialog();

  @override
  State<_AddCompetitorDialog> createState() => _AddCompetitorDialogState();
}

class _AddCompetitorDialogState extends State<_AddCompetitorDialog> {
  final _nameController = TextEditingController();
  final _bibController = TextEditingController();
  BiathlonRaceType _raceType = BiathlonRaceType.sprint;
  int _customLaps = 3;
  List<ShootingPosition> _customBouts = [ShootingPosition.prone, ShootingPosition.standing];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Add Competitor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bibController,
              decoration: const InputDecoration(labelText: 'Bib Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Race Type', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BiathlonRaceType>(
                  value: _raceType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E293B),
                  items: BiathlonRaceType.values.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type.displayName));
                  }).toList(),
                  onChanged: (v) => setState(() => _raceType = v!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _raceType.description,
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (_raceType == BiathlonRaceType.custom) ...[
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Text('Laps', style: TextStyle(fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: _customLaps > 1 ? () => setState(() => _customLaps--) : null,
                    icon: const Icon(LucideIcons.minusCircle, size: 20, color: Color(0xFF38BDF8)),
                  ),
                  Text('$_customLaps', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _customLaps < 10 ? () => setState(() => _customLaps++) : null,
                    icon: const Icon(LucideIcons.plusCircle, size: 20, color: Color(0xFF38BDF8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Bouts', style: TextStyle(fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: _customBouts.length > 1 ? () => setState(() => _customBouts.removeLast()) : null,
                    icon: const Icon(LucideIcons.minusCircle, size: 20, color: Color(0xFFFACC15)),
                  ),
                  Text('${_customBouts.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _customBouts.length < 10 ? () => setState(() => _customBouts.add(ShootingPosition.prone)) : null,
                    icon: const Icon(LucideIcons.plusCircle, size: 20, color: Color(0xFFFACC15)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(_customBouts.length, (i) => ActionChip(
                  label: Text(_customBouts[i] == ShootingPosition.prone ? 'PRONE' : 'STAND'),
                  backgroundColor: _customBouts[i] == ShootingPosition.prone ? const Color(0xFF38BDF8).withOpacity(0.2) : const Color(0xFFFACC15).withOpacity(0.2),
                  side: BorderSide(color: _customBouts[i] == ShootingPosition.prone ? const Color(0xFF38BDF8) : const Color(0xFFFACC15), width: 1),
                  onPressed: () => setState(() {
                    _customBouts[i] = _customBouts[i] == ShootingPosition.prone ? ShootingPosition.standing : ShootingPosition.prone;
                  }),
                )),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        Consumer(builder: (ctx, ref, _) {
          return ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _bibController.text.isNotEmpty) {
                ref.read(biathlonCoachProvider.notifier).addCompetitor(
                  _nameController.text,
                  _bibController.text,
                  _raceType,
                  lapCount: _raceType == BiathlonRaceType.custom ? _customLaps : null,
                  customBouts: _raceType == BiathlonRaceType.custom ? _customBouts : null,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          );
        }),
      ],
    );
  }
}

class _RaceSplits extends StatelessWidget {
  final RaceCompetitor competitor;
  const _RaceSplits({required this.competitor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RACE SPLITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 12),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    List<Widget> rows = [];
    
    for (int i = 0; i < competitor.lapCount; i++) {
      // Lap Data
      if (i < competitor.laps.length) {
        final lap = competitor.laps[i];
        rows.add(_SplitRow(
          label: 'Lap ${i + 1}',
          start: lap.startTime,
          end: lap.endTime,
          color: const Color(0xFF38BDF8),
        ));
      }

      // Shoot Data
      if (i < competitor.shoots.length) {
        final shoot = competitor.shoots[i];
        if (shoot.startTime != null || shoot.endTime != null) {
          rows.add(_SplitRow(
            label: 'Shoot ${i + 1}',
            start: shoot.startTime,
            end: shoot.endTime,
            color: const Color(0xFFF472B6),
          ));
        }
      }
    }

    // Penalty Row
    if (competitor.totalPenaltyTime > Duration.zero) {
      rows.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1, color: Colors.white10),
      ));
      rows.add(_SplitRow(
        label: 'Penalties',
        start: Duration.zero,
        end: competitor.totalPenaltyTime,
        color: const Color(0xFFEF4444),
      ));
    }

    // Always show a summary if it's an individual/custom race (where penalties matter)
    if (competitor.raceType.penaltySecondsPerMiss > 0) {
      rows.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1, color: Colors.white10),
      ));
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('TOTAL PENALTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
          Text('+ ${_formatDuration(competitor.totalPenaltyTime)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontFamily: 'monospace')),
        ],
      ));
    }

    return Column(children: rows);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.white54,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  final String label;
  final Duration? start;
  final Duration? end;
  final Color color;

  const _SplitRow({required this.label, this.start, this.end, required this.color});

  @override
  Widget build(BuildContext context) {
    final duration = (start != null && end != null) ? end! - start! : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              start != null ? _formatDuration(start!) : '--:--',
              style: const TextStyle(fontFamily: 'monospace', color: Colors.white38, fontSize: 12),
            ),
          ),
          const Icon(LucideIcons.arrowRight, size: 12, color: Colors.white10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              end != null ? _formatDuration(end!) : '--:--',
              style: const TextStyle(fontFamily: 'monospace', color: Colors.white38, fontSize: 12),
            ),
          ),
          if (duration != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(
                _formatDuration(duration),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.users, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('No competitors added yet', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onAdd, child: const Text('ADD COMPETITOR')),
        ],
      ),
    );
  }
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMicros(int n) => (n ~/ 100000).toString(); // tenth of second
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  final tenths = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
  return "$minutes:$seconds.$tenths";
}
