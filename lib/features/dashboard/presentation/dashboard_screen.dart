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
    final selectedHabit = habitsState.selectedHabit;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _HabitSidebar(state: habitsState),
                  Expanded(child: _HabitDetail(habit: selectedHabit)),
                ],
              ),
            ),
          ],
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
      width: 340,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: PlotTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 18, 28),
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
          for (final habit in state.habits) ...[
            _HabitListTile(
              habit: habit,
              selected: habit.id == state.selectedHabitId,
              onTap: () => ref
                  .read(habitsControllerProvider.notifier)
                  .selectHabit(habit.id),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {},
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
          const Spacer(),
          const Divider(color: PlotTheme.border),
          const SizedBox(height: 12),
          Text(
            'Click a day to plant it. Click again to clear it.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
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
          padding: const EdgeInsets.all(16),
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
              _MiniCells(color: habit.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCells extends StatelessWidget {
  const _MiniCells({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        6,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: index == 0
                ? color.withValues(alpha: 0.28)
                : PlotTheme.border.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _HabitDetail extends ConsumerWidget {
  const _HabitDetail({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 42, 44, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ColorChip(color: habit.color, size: 18),
              const SizedBox(width: 16),
              Text(habit.name, style: Theme.of(context).textTheme.displaySmall),
              const Spacer(),
              _IconBox(
                icon: Icons.edit_outlined,
                onPressed: () => _showEditHabitDialog(context, ref, habit),
              ),
              const SizedBox(width: 12),
              _IconBox(icon: Icons.close, onPressed: () {}),
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

          const SizedBox(height: 30),
          ContributionCalendar(
            habit: habit,
            onToggleDay: ref
                .read(habitsControllerProvider.notifier)
                .togglePlantedDay,
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onPressed});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: PlotTheme.surface,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: PlotTheme.muted,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.color, required this.size});

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

Future<void> _showEditHabitDialog(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditHabitDialog(habit: habit, ref: ref),
  );
}

class _EditHabitDialog extends StatefulWidget {
  const _EditHabitDialog({required this.habit, required this.ref});

  final Habit habit;
  final WidgetRef ref;

  @override
  State<_EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<_EditHabitDialog> {
  static const colors = [
    Color(0xFFE3B567),
    Color(0xFFD88360),
    Color(0xFF69AC9A),
    Color(0xFF9A87C8),
    Color(0xFFB6CB6B),
    Color(0xFF83B3D1),
  ];

  late final TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedColor = widget.habit.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PlotTheme.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PlotTheme.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 470),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit habit',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'NAME'),
              ),
              const SizedBox(height: 26),
              Text(
                'COLOR',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PlotTheme.muted,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final color in colors)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedColor = color),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color == _selectedColor
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      widget.ref
                          .read(habitsControllerProvider.notifier)
                          .updateSelectedHabit(
                            name: _nameController.text.trim(),
                            color: _selectedColor,
                          );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
