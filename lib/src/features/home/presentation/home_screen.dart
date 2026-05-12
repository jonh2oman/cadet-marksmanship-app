import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/disclaimer_dialog.dart';
import '../../../theme/app_theme.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DisclaimerDialog.showIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeSwitcher(ref, themeMode),
                      IconButton(
                        icon: const Icon(LucideIcons.settings),
                        onPressed: () {}, // Future settings
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'WELCOME TO THE MARKSMANSHIP TOOL',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Marksmanship Tool',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a discipline to begin your session.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDisciplineCard(
                          context,
                          title: 'Marksmanship',
                          subtitle: 'Air Rifle & Grouping',
                          icon: LucideIcons.target,
                          color: AppTheme.primaryMarksmanship,
                          onTap: () => context.push('/marksmanship'),
                        ),
                        const SizedBox(height: 24),
                        _buildDisciplineCard(
                          context,
                          title: 'Biathlon',
                          subtitle: 'Skiing/Running & Shooting',
                          icon: LucideIcons.crosshair,
                          color: AppTheme.primaryBiathlon,
                          onTap: () => context.push('/biathlon'),
                        ),
                        const SizedBox(height: 24),
                        _buildDisciplineCard(
                          context,
                          title: 'Scoring Only',
                          subtitle: 'Quick Calculator & Results',
                          icon: LucideIcons.clipboardCheck,
                          color: AppTheme.gold,
                          onTap: () => context.push('/scoring'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'v1.2.0',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: Colors.white10)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.push('/changelog'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'CHANGE LOG',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitcher(WidgetRef ref, AppThemeMode currentMode) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeIcon(ref, AppThemeMode.light, LucideIcons.sun, currentMode),
          _themeIcon(ref, AppThemeMode.dark, LucideIcons.moon, currentMode),
          _themeIcon(ref, AppThemeMode.sea, LucideIcons.waves, currentMode),
          _themeIcon(ref, AppThemeMode.system, LucideIcons.monitor, currentMode),
        ],
      ),
    );
  }

  Widget _themeIcon(WidgetRef ref, AppThemeMode mode, IconData icon, AppThemeMode currentMode) {
    final isSelected = mode == currentMode;
    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).state = mode,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDisciplineCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      opacity: 0.05,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight),
            ],
          ),
        ),
      ),
    );
  }
}
