import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/glass/glass_chip.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';
import 'schedule_makeup_dialog.dart';

class MakeupSessionsScreen extends HookConsumerWidget {
  final String subjectId;

  const MakeupSessionsScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(watchSessionsBySubjectProvider(subjectId));

    return GlassScaffold(
      title: 'Make-up Sessions',
      body: sessionsAsync.when(
        data: (sessions) {
          // Filter makeup sessions
          final makeupSessions = sessions
              .where((s) => s.type == 'makeup')
              .toList()
            ..sort((a, b) => a.plannedAt.compareTo(b.plannedAt));

          if (makeupSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No make-up sessions',
                    style: GlassTheme.titleMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: makeupSessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = makeupSessions[index];
              return _MakeupSessionCard(session: session);
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
    );
  }
}

class _MakeupSessionCard extends HookConsumerWidget {
  final LabSession session;

  const _MakeupSessionCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(watchAttendanceBySessionProvider(session.id));

    return attendanceAsync.when(
      data: (attendance) {
        if (attendance == null) {
          return const SizedBox.shrink();
        }

        final status = AttendanceStatus.fromString(attendance.status);
        final plannedAt = AppDateUtils.fromIso8601(session.plannedAt);
        final isScheduled = status == AttendanceStatus.makeupScheduled;
        final isAttended = status == AttendanceStatus.makeupAttended;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isScheduled || isAttended
                              ? AppDateUtils.formatDate(plannedAt)
                              : 'Not scheduled yet',
                          style: GlassTheme.titleMedium.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                          ),
                        ),
                        if (isScheduled || isAttended) ...[
                          const SizedBox(height: 4),
                          Text(
                            AppDateUtils.formatTime(plannedAt),
                            style: GlassTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GlassChip(
                    label: isAttended ? 'Attended' : (isScheduled ? 'Scheduled' : 'Unscheduled'),
                    style: isAttended ? ChipStyle.attended : ChipStyle.makeup,
                    icon: isAttended
                        ? Icons.check_circle_rounded
                        : Icons.event_available_rounded,
                  ),
                ],
              ),
              if (session.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.location!,
                      style: GlassTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Actions
              if (!isAttended) ...[
                if (!isScheduled)
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.25),
                        builder: (context) => ScheduleMakeupDialog(session: session),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: const Text('Schedule Date & Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () async {
                      final repo = ref.read(attendanceRepoProvider);
                      final result = await repo.markMakeupAttended(session.id);
                      if (context.mounted) {
                        if (result.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Make-up session marked as attended')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.errorOrNull ?? 'Failed')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Mark Attended'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x2E4CD964),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
      loading: () => const GlassCard(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
      ),
      error: (error, stack) => GlassCard(
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
          ),
        ),
      ),
    );
  }
}

