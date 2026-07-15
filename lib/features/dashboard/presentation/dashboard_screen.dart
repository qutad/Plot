import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot/core/theme/plot_theme.dart';
import 'package:plot/features/habits/application/habits_controller.dart';
import 'package:plot/features/habits/domain/habit.dart';
import 'package:plot/widgets/contribution_calendar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: habitsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Failed to load habits: $error'),
          ),
          data: (state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1024) {
                  return _MobileDashboard(state: state);
                }

                return _DesktopDashboard(state: state);
              },
            );
          },
        ),
      ),
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context) {
    final selectedHabit = state.selectedHabit;

    return Row(
      key: const Key('desktop-dashboard'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HabitSidebar(state: state),
        Expanded(
          child: selectedHabit == null
              ? Center(
                  child: Text(
                    'No habits',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: PlotTheme.muted,
                      fontFamily: PlotTheme.monoFont,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              : _HabitDetail(habit: selectedHabit),
        ),
      ],
    );
  }
}

class _MobileDashboard extends ConsumerWidget {
  const _MobileDashboard({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabit = state.selectedHabit;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 16.0 : 20.0;

    return SingleChildScrollView(
      key: const Key('mobile-dashboard'),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileHeader(
            onAdd: () => _showCreateHabitForm(context, ref, compact: true),
          ),
          const SizedBox(height: 26),
          if (state.habits.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.habits.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final habit = state.habits[index];

                  return _MobileHabitChip(
                    habit: habit,
                    selected: habit.id == state.selectedHabitId,
                    onTap: () {
                      ref
                          .read(habitsControllerProvider.notifier)
                          .selectHabit(habit.id);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          if (selectedHabit == null)
            const _MobileEmptyState()
          else
            _MobileSelectedHabit(habit: selectedHabit),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            text: 'Plot',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 30,
            ),
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: PlotTheme.gold),
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onAdd,
          tooltip: 'Add habit',
          style: IconButton.styleFrom(
            foregroundColor: PlotTheme.ink,
            backgroundColor: PlotTheme.gold,
            fixedSize: const Size.square(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, size: 24),
        ),
      ],
    );
  }
}

class _MobileHabitChip extends StatelessWidget {
  const _MobileHabitChip({
    required this.habit,
    required this.selected,
    required this.onTap,
  });

  final Habit habit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: habit.name,
      child: Material(
        color: selected ? PlotTheme.surfaceRaised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: selected
                ? PlotTheme.border
                : PlotTheme.border.withValues(alpha: 0.6),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ColorChip(color: habit.color, size: 9),
                const SizedBox(width: 9),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selected ? PlotTheme.text : PlotTheme.muted,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _HabitAction {
  edit,
  delete,
}

class _MobileSelectedHabit extends ConsumerWidget {
  const _MobileSelectedHabit({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ColorChip(color: habit.color, size: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                habit.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<_HabitAction>(
              key: const Key('mobile-habit-actions'),
              tooltip: 'Habit actions',
              color: PlotTheme.surfaceRaised,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: PlotTheme.border),
              ),
              icon: const Icon(
                Icons.more_horiz,
                color: PlotTheme.muted,
              ),
              onSelected: (action) async {
                switch (action) {
                  case _HabitAction.edit:
                    await _showEditHabitForm(
                      context,
                      ref,
                      habit,
                      compact: true,
                    );
                  case _HabitAction.delete:
                    await _showDeleteHabitDialog(context, ref, habit);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _HabitAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 12),
                      Text('Edit habit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _HabitAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 12),
                      Text('Delete habit'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _MobileStatistics(habit: habit),
        const SizedBox(height: 22),
        ContributionCalendar(
          habit: habit,
          compact: true,
          onToggleDay: ref
              .read(habitsControllerProvider.notifier)
              .togglePlantedDay,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Tap a day to plant it. Tap again to clear it.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PlotTheme.muted,
              fontFamily: PlotTheme.monoFont,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileStatistics extends StatelessWidget {
  const _MobileStatistics({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MobileStatCard(
        value: habit.currentStreak.toString(),
        label: 'CURRENT\nSTREAK',
      ),
      _MobileStatCard(
        value: habit.longestStreak.toString(),
        label: 'LONGEST\nSTREAK',
      ),
      _MobileStatCard(
        value: habit.daysPlantedLast52Weeks.toString(),
        label: 'DAYS\nPLANTED',
      ),
    ];
    final stackCards = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return SizedBox(
      key: const Key('mobile-statistics'),
      child: stackCards
          ? Column(
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  SizedBox(width: double.infinity, child: cards[index]),
                  if (index != cards.length - 1) const SizedBox(height: 8),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  Expanded(child: cards[index]),
                  if (index != cards.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  const _MobileStatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: PlotTheme.surface,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: PlotTheme.monoFont,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            maxLines: 2,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: PlotTheme.muted,
              fontFamily: PlotTheme.monoFont,
              fontSize: 9,
              height: 1.25,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileEmptyState extends StatelessWidget {
  const _MobileEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Center(
        child: Text(
          'Add your first habit',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: PlotTheme.muted,
            fontFamily: PlotTheme.monoFont,
          ),
        ),
      ),
    );
  }
}

class _HabitSidebar extends ConsumerWidget {
  const _HabitSidebar({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: PlotTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Plot',
              style: Theme.of(context).textTheme.displaySmall,
              children: const [
                TextSpan(
                  text: '.',
                  style: TextStyle(color: PlotTheme.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.separated(
              itemCount: state.habits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                return _HabitListTile(
                  habit: habit,
                  selected: habit.id == state.selectedHabitId,
                  onTap: () => ref
                      .read(habitsControllerProvider.notifier)
                      .selectHabit(habit.id),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showCreateHabitForm(
              context,
              ref,
              compact: false,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New habit'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: PlotTheme.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: PlotTheme.border),
          const SizedBox(height: 12),
          Text(
            'Click a day to plant it. Click again to clear it.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: PlotTheme.monoFont,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitListTile extends StatelessWidget {
  const _HabitListTile({
    required this.habit,
    required this.selected,
    required this.onTap,
  });

  final Habit habit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PlotTheme.surfaceRaised : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? PlotTheme.border : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ColorChip(color: habit.color, size: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'no streak yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _MiniCells(habit: habit),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCells extends StatelessWidget {
  const _MiniCells({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final today = Habit.civilDate(DateTime.now());
    final weekStart = Habit.addCivilDays(today, -(today.weekday - 1));
    final plantedDays = {
      for (final day in habit.plantedDays) Habit.civilDate(day),
    };

    return Row(
      children: List.generate(
        DateTime.daysPerWeek,
        (index) {
          final day = Habit.addCivilDays(weekStart, index);
          final planted = plantedDays.contains(day);

          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: planted
                  ? habit.color
                  : PlotTheme.border.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }
}

class _HabitDetail extends ConsumerWidget {
  const _HabitDetail({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ColorChip(color: habit.color, size: 18),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(width: 16),
                _IconBox(
                  icon: Icons.edit_outlined,
                  onPressed: () => _showEditHabitForm(
                    context,
                    ref,
                    habit,
                    compact: false,
                  ),
                ),
                const SizedBox(width: 12),
                _IconBox(
                  icon: Icons.close,
                  onPressed: () => _showDeleteHabitDialog(context, ref, habit),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: habit.currentStreak.toString(),
                    label: 'CURRENT STREAK',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    value: habit.longestStreak.toString(),
                    label: 'LONGEST STREAK',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    value: habit.daysPlantedLast52Weeks.toString(),
                    label: 'DAYS PLANTED (52WK)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ContributionCalendar(
              habit: habit,
              onToggleDay: ref
                  .read(habitsControllerProvider.notifier)
                  .togglePlantedDay,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(42),
        side: const BorderSide(color: PlotTheme.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: PlotTheme.surface,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: PlotTheme.muted,
              fontFamily: PlotTheme.monoFont,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

Future<void> _showEditHabitForm(
  BuildContext context,
  WidgetRef ref,
  Habit habit, {
  required bool compact,
}) {
  return _showHabitForm(
    context,
    compact: compact,
    title: 'Edit habit',
    initialName: habit.name,
    initialColor: habit.color,
    onSave: (name, color) {
      return ref
          .read(habitsControllerProvider.notifier)
          .updateSelectedHabit(name: name, color: color);
    },
  );
}

Future<void> _showDeleteHabitDialog(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete habit?'),
      content: Text('This will permanently delete ${habit.name}.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await ref
                .read(habitsControllerProvider.notifier)
                .deleteSelectedHabit();

            if (!context.mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

Future<void> _showCreateHabitForm(
  BuildContext context,
  WidgetRef ref, {
  required bool compact,
}) {
  return _showHabitForm(
    context,
    compact: compact,
    title: 'New habit',
    initialName: '',
    initialColor: PlotTheme.gold,
    onSave: (name, color) {
      return ref
          .read(habitsControllerProvider.notifier)
          .addHabit(name: name, color: color);
    },
  );
}

Future<void> _showHabitForm(
  BuildContext context, {
  required bool compact,
  required String title,
  required String initialName,
  required Color initialColor,
  required Future<void> Function(String name, Color color) onSave,
}) {
  if (!compact) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        key: const Key('habit-form-dialog'),
        backgroundColor: PlotTheme.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PlotTheme.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: _HabitForm(
            title: title,
            initialName: initialName,
            initialColor: initialColor,
            onSave: onSave,
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          key: const Key('habit-form-sheet'),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: PlotTheme.surfaceRaised,
            border: Border(
              top: BorderSide(color: PlotTheme.border),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _HabitForm(
            title: title,
            initialName: initialName,
            initialColor: initialColor,
            onSave: onSave,
            compact: true,
          ),
        ),
      );
    },
  );
}

class _HabitForm extends StatefulWidget {
  const _HabitForm({
    required this.title,
    required this.initialName,
    required this.initialColor,
    required this.onSave,
    this.compact = false,
  });

  final String title;
  final String initialName;
  final Color initialColor;
  final Future<void> Function(String name, Color color) onSave;
  final bool compact;

  @override
  State<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<_HabitForm> {
  static const colors = [
    Color(0xFFE3B567),
    Color(0xFFD88360),
    Color(0xFF69AC9A),
    Color(0xFF9A87C8),
    Color(0xFFB6CB6B),
    Color(0xFF83B3D1),
  ];

  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  late Color _selectedColor;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.compact ? 24 : 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.compact) ...[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PlotTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 26),
            TextFormField(
              key: const Key('habit-name-field'),
              controller: _nameController,
              autofocus: widget.compact,
              enabled: !_saving,
              maxLength: 40,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'NAME'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Text(
              'COLOR',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: PlotTheme.muted,
                fontFamily: PlotTheme.monoFont,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var index = 0; index < colors.length; index++)
                  Semantics(
                    button: true,
                    selected: colors[index] == _selectedColor,
                    label: 'Color option ${index + 1}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saving
                            ? null
                            : () {
                                setState(() => _selectedColor = colors[index]);
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.square(
                          dimension: 48,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors[index],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors[index] == _selectedColor
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 18),
              Text(
                _saveError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  key: const Key('habit-form-save'),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await widget.onSave(_nameController.text.trim(), _selectedColor);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Could not save the habit. Try again.';
        });
      }
    }
  }
}
