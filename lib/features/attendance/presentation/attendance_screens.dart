import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_models.dart';

class AttendanceListScreen extends ConsumerWidget {
  const AttendanceListScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.attendanceList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final asyncDays = ref.watch(attendanceDaysProvider((orgId: orgId, engagementId: engagementId)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgAttendanceList),
      ),
      body: KaamAsyncBody<List<AttendanceDay>>(
        isLoading: asyncDays.isLoading,
        errorMessage: asyncDays.hasError ? asyncDays.error.toString() : null,
        data: asyncDays.value,
        onRetry: () => ref.refresh(attendanceDaysProvider((orgId: orgId, engagementId: engagementId))),
        dataBuilder: (context, days) {
          if (days.isEmpty) {
            return Center(
              child: KaamEmptyState(
                title: l10n.emptyStateTitle,
                onAction: () {
                  context.push(AppPaths.orgAttendanceNew(orgId, engagementId));
                },
              ),
            );
          }

          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              return Card(
                child: ListTile(
                  title: Text(DateFormat.yMMMMd().format(day.date)),
                  subtitle: Text(
                    '${day.presentWorkers} / ${day.totalWorkers} workers present',
                  ),
                  trailing: day.isLocked
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(AppPaths.orgAttendanceDay(orgId, engagementId, day.id));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppPaths.orgAttendanceNew(orgId, engagementId));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AttendanceDayNewScreen extends ConsumerStatefulWidget {
  const AttendanceDayNewScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
  });

  final String orgId;
  final String engagementId;

  static const String name = RouteNames.attendanceNew;

  @override
  ConsumerState<AttendanceDayNewScreen> createState() => _AttendanceDayNewScreenState();
}

class _AttendanceDayNewScreenState extends ConsumerState<AttendanceDayNewScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgAttendanceNew),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Text(
                      'Select Date',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      DateFormat.yMMMMEEEEd().format(_selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 7)),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () async {
                final newDay = AttendanceDay(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  orgId: widget.orgId,
                  engagementId: widget.engagementId,
                  date: _selectedDate,
                );
                await ref.read(attendanceRepositoryProvider).addAttendanceDay(newDay);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ref.invalidate(attendanceDaysProvider);
                }
              },
              child: const Text('Create Attendance Day'),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceDayScreen extends ConsumerWidget {
  const AttendanceDayScreen({
    super.key,
    required this.orgId,
    required this.engagementId,
    required this.dayId,
  });

  final String orgId;
  final String engagementId;
  final String dayId;

  static const String name = RouteNames.attendanceDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final asyncDay = ref.watch(attendanceDayProvider(dayId));
    final asyncPunches = ref.watch(timePunchesProvider(dayId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgAttendanceDay),
        actions: [
          asyncDay.when(
            data: (day) => day != null && !day.isLocked
                ? IconButton(
                    icon: const Icon(Icons.lock_open),
                    onPressed: () async {
                      await ref.read(attendanceRepositoryProvider).lockAttendanceDay(dayId);
                      ref.invalidate(attendanceDayProvider(dayId));
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: KaamAsyncBody<AttendanceDay?>(
        isLoading: asyncDay.isLoading,
        errorMessage: asyncDay.hasError ? asyncDay.error.toString() : null,
        data: asyncDay.value,
        dataBuilder: (context, day) {
          if (day == null) return const Center(child: Text('Day not found'));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: Text(DateFormat.yMMMMd().format(day.date)),
                  subtitle: Text('Status: ${day.status.toUpperCase()}'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Worker Attendance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: asyncPunches.when(
                  data: (punches) => ListView.builder(
                    itemCount: punches.length,
                    itemBuilder: (context, index) {
                      final punch = punches[index];
                      return ListTile(
                        title: Text('Worker ID: ${punch.workerId}'),
                        subtitle: Text(
                          punch.checkIn != null
                              ? 'In: ${DateFormat.jm().format(punch.checkIn!)}'
                              : 'Not checked in',
                        ),
                        trailing: Checkbox(
                          value: punch.isPresent,
                          onChanged: day.isLocked
                              ? null
                              : (val) {
                                  // Update punch status
                                },
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error: $err'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TimePunchScreen extends StatelessWidget {
  const TimePunchScreen({super.key, required this.orgId, required this.dayId});

  final String orgId;
  final String dayId;

  static const String name = RouteNames.timePunch;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return KaamPlaceholderPage(
      title: l10n.pgTimePunch,
      metadata: 'orgId: $orgId, dayId: $dayId — POST /attendance_days/:id/time_punches',
    );
  }
}
