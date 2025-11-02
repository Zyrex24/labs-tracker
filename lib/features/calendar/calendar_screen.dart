import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/glass/glass_chip.dart';
import '../../app/theme/glass_theme.dart';
import '../../app/router/app_router.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';
import '../../domain/attendance_state_machine.dart';

class CalendarScreen extends HookConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(watchAllSessionsProvider);
    final subjectsAsync = ref.watch(watchAllSubjectsProvider);
    final selectedSubjectId = useState<String?>(null);
    final windowHours = ref.watch(notificationWindowHoursProvider);

    return GlassScaffold(
      title: 'Calendar',
      body: Column(
        children: [
          // Subject filter
          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All subjects chip
                      GestureDetector(
                        onTap: () => selectedSubjectId.value = null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selectedSubjectId.value == null
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            'All',
                            style: GlassTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Subject chips
                      ...subjects.map((subject) {
                        final isSelected = selectedSubjectId.value == subject.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => selectedSubjectId.value = subject.id,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                subject.code,
                                style: GlassTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Sessions list
          Expanded(
            child: sessionsAsync.when(
              data: (allSessions) {
                // Filter by subject if selected
                final sessions = selectedSubjectId.value != null
                    ? allSessions.where((s) => s.subjectId == selectedSubjectId.value).toList()
                    : allSessions;

                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 64,
                          color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sessions scheduled',
                          style: GlassTheme.titleMedium.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group sessions by date
                final groupedSessions = _groupSessionsByDate(sessions);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedSessions.length,
                  itemBuilder: (context, index) {
                    final entry = groupedSessions.entries.elementAt(index);
                    final date = entry.key;
                    final dateSessions = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              _formatDateHeader(date),
                              style: GlassTheme.titleSmall.copyWith(
                                color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                              ),
                            ),
                          ),
                        ),
                        // Sessions for this date
                        ...dateSessions.map((session) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SessionCard(
                              session: session,
                              windowHours: windowHours,
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<LabSession>> _groupSessionsByDate(List<LabSession> sessions) {
    final Map<DateTime, List<LabSession>> grouped = {};

    for (final session in sessions) {
      final plannedAt = AppDateUtils.fromIso8601(session.plannedAt);
      final dateOnly = DateTime(plannedAt.year, plannedAt.month, plannedAt.day);

      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(session);
    }

    // Sort by date
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Today, ${AppDateUtils.formatDate(date)}';
    } else if (date == tomorrow) {
      return 'Tomorrow, ${AppDateUtils.formatDate(date)}';
    } else {
      return AppDateUtils.formatDate(date);
    }
  }
}

class _SessionCard extends HookConsumerWidget {
  final LabSession session;
  final int windowHours;

  const _SessionCard({
    required this.session,
    required this.windowHours,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(watchAllSubjectsProvider);
    final attendanceAsync = ref.watch(watchAttendanceBySessionProvider(session.id));

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.sessionDetail,
          arguments: session,
        );
      },
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name
                  subjectAsync.when(
                    data: (subjects) {
                      final subject = subjects.firstWhere(
                        (s) => s.id == session.subjectId,
                        orElse: () => Subject(
                          id: '',
                          name: 'Unknown',
                          code: '',
                          labsRequired: 0,
                        ),
                      );
                      return Text(
                        subject.name,
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 4),
                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatTime(AppDateUtils.fromIso8601(session.plannedAt)),
                        style: GlassTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                        ),
                      ),
                      if (session.location != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            session.location!,
                            style: GlassTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Type chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: session.type == 'regular'
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0x2E007AFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: session.type == 'regular'
                                ? Colors.white.withOpacity(0.24)
                                : const Color(0xA6007AFF),
                          ),
                        ),
                        child: Text(
                          session.type == 'regular' ? 'Regular' : 'Make-up',
                          style: GlassTheme.caption.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status chip
            attendanceAsync.when(
              data: (attendance) {
                if (attendance == null) {
                  return const SizedBox.shrink();
                }

                final status = AttendanceStatus.fromString(attendance.status);
                final plannedAt = AppDateUtils.fromIso8601(session.plannedAt);
                final currentStatus = AttendanceStateMachine.determineStatus(
                  plannedAt: plannedAt,
                  windowHours: windowHours,
                  currentStatus: status,
                );

                return _StatusChip(status: currentStatus);
              },
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (chipStyle, icon) = _getStatusInfo(status);

    return GlassChip(
      label: '',
      style: chipStyle,
      icon: icon,
      compact: true,
    );
  }

  (ChipStyle, IconData) _getStatusInfo(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.notReady => (ChipStyle.notReady, Icons.schedule_rounded),
      AttendanceStatus.due => (ChipStyle.due, Icons.notification_important_rounded),
      AttendanceStatus.attended => (ChipStyle.attended, Icons.check_circle_rounded),
      AttendanceStatus.missed => (ChipStyle.missed, Icons.cancel_rounded),
      AttendanceStatus.sickPending => (ChipStyle.sickPending, Icons.pending_rounded),
      AttendanceStatus.sickSubmitted => (ChipStyle.sickSubmitted, Icons.description_rounded),
      AttendanceStatus.makeupScheduled => (ChipStyle.makeup, Icons.event_available_rounded),
      AttendanceStatus.makeupAttended => (ChipStyle.attended, Icons.check_circle_rounded),
    };
  }
}

