import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/glass/glass_chip.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';
import '../../domain/attendance_state_machine.dart';
import '../sicknotes/sick_note_dialog.dart';

class SessionDetailScreen extends HookConsumerWidget {
  final LabSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(watchAttendanceBySessionProvider(session.id));
    final windowHours = ref.watch(notificationWindowHoursProvider);

    return GlassScaffold(
      title: 'Session Detail',
      body: attendanceAsync.when(
        data: (attendance) {
          if (attendance == null) {
            return const Center(child: Text('No attendance record found'));
          }

          final status = AttendanceStatus.fromString(attendance.status);
          final plannedAt = AppDateUtils.fromIso8601(session.plannedAt);
          
          // Determine current status based on time
          final currentStatus = AttendanceStateMachine.determineStatus(
            plannedAt: plannedAt,
            windowHours: windowHours,
            currentStatus: status,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session info card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Information',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: AppDateUtils.formatDate(plannedAt),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: AppDateUtils.formatTime(plannedAt),
                      ),
                      if (session.location != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          value: session.location!,
                        ),
                      ],
                      if (session.slot != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Slot',
                          value: session.slot!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.category_rounded,
                        label: 'Type',
                        value: session.type == 'regular' ? 'Regular' : 'Make-up',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Status',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StatusChip(status: currentStatus),
                      if (attendance.note != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Note: ${attendance.note}',
                          style: GlassTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Actions
                _ActionButtons(
                  session: session,
                  attendance: attendance,
                  currentStatus: currentStatus,
                ),
              ],
            ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GlassTheme.caption.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GlassTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (chipStyle, icon, label) = _getStatusInfo(status);
    
    return GlassChip(
      label: label,
      style: chipStyle,
      icon: icon,
    );
  }

  (ChipStyle, IconData, String) _getStatusInfo(AttendanceStatus status) {
    return switch (status) {
      AttendanceStatus.notReady => (
        ChipStyle.notReady,
        Icons.schedule_rounded,
        'Not Ready'
      ),
      AttendanceStatus.due => (
        ChipStyle.due,
        Icons.notification_important_rounded,
        'Due Now'
      ),
      AttendanceStatus.attended => (
        ChipStyle.attended,
        Icons.check_circle_rounded,
        'Attended'
      ),
      AttendanceStatus.missed => (
        ChipStyle.missed,
        Icons.cancel_rounded,
        'Missed'
      ),
      AttendanceStatus.sickPending => (
        ChipStyle.sickPending,
        Icons.pending_rounded,
        'Sick Note Pending'
      ),
      AttendanceStatus.sickSubmitted => (
        ChipStyle.sickSubmitted,
        Icons.description_rounded,
        'Sick Note Submitted'
      ),
      AttendanceStatus.makeupScheduled => (
        ChipStyle.makeup,
        Icons.event_available_rounded,
        'Make-up Scheduled'
      ),
      AttendanceStatus.makeupAttended => (
        ChipStyle.attended,
        Icons.check_circle_rounded,
        'Make-up Attended'
      ),
    };
  }
}

class _ActionButtons extends HookConsumerWidget {
  final LabSession session;
  final AttendanceData attendance;
  final AttendanceStatus currentStatus;

  const _ActionButtons({
    required this.session,
    required this.attendance,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(attendanceRepoProvider);

    // Show actions based on current status
    if (currentStatus == AttendanceStatus.due) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final result = await repo.markAttended(session.id);
              if (context.mounted) {
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as attended')),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await repo.markMissed(session.id);
              if (context.mounted) {
                if (result.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as missed')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.errorOrNull ?? 'Failed')),
                  );
                }
              }
            },
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Mark Missed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0x2EFF3B30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.25),
                builder: (context) => SickNoteDialog(session: session),
              );
            },
            icon: const Icon(Icons.description_rounded),
            label: const Text('Submit Sick Note'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      );
    }

    // Allow undo for attended/missed
    if (currentStatus == AttendanceStatus.attended ||
        currentStatus == AttendanceStatus.missed) {
      return OutlinedButton.icon(
        onPressed: () async {
          final result = await repo.updateAttendanceStatus(
            labSessionId: session.id,
            status: AttendanceStatus.due,
          );
          if (context.mounted) {
            if (result.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status reset to Due')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.errorOrNull ?? 'Failed')),
              );
            }
          }
        },
        icon: const Icon(Icons.undo_rounded),
        label: const Text('Undo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

