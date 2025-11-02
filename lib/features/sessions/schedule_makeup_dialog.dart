import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_dialog.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';

class ScheduleMakeupDialog extends HookConsumerWidget {
  final LabSession session;

  const ScheduleMakeupDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);
    final isLoading = useState(false);

    return GlassDialog(
      title: 'Schedule Make-up Session',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose a date and time for your make-up session',
            style: GlassTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
            ),
          ),
          const SizedBox(height: 24),
          
          // Date picker button
          OutlinedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value ?? now.add(const Duration(days: 7)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF6A85F1),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1E1E1E),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      selectedDate.value = date;
                    }
                  },
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text(
              selectedDate.value != null
                  ? AppDateUtils.formatDate(selectedDate.value!)
                  : 'Select Date',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          
          // Time picker button
          OutlinedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime.value ?? const TimeOfDay(hour: 9, minute: 0),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF6A85F1),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1E1E1E),
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      selectedTime.value = time;
                    }
                  },
            icon: const Icon(Icons.access_time_rounded),
            label: Text(
              selectedTime.value != null
                  ? selectedTime.value!.format(context)
                  : 'Select Time',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          
          if (selectedDate.value != null && selectedTime.value != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Date & time selected',
                      style: GlassTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: (isLoading.value || selectedDate.value == null || selectedTime.value == null)
              ? null
              : () async {
                  isLoading.value = true;
                  
                  // Combine date and time
                  final scheduledDateTime = DateTime(
                    selectedDate.value!.year,
                    selectedDate.value!.month,
                    selectedDate.value!.day,
                    selectedTime.value!.hour,
                    selectedTime.value!.minute,
                  );
                  
                  // Update session planned_at
                  final sessionsRepo = ref.read(sessionsRepoProvider);
                  final updateResult = await sessionsRepo.updateSession(
                    session.id,
                    plannedAt: scheduledDateTime,
                  );
                  
                  if (updateResult.isFailure) {
                    if (context.mounted) {
                      isLoading.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(updateResult.errorOrNull ?? 'Failed to schedule')),
                      );
                    }
                    return;
                  }
                  
                  // Update attendance status to makeup_scheduled
                  final attendanceRepo = ref.read(attendanceRepoProvider);
                  final statusResult = await attendanceRepo.updateAttendanceStatus(
                    labSessionId: session.id,
                    status: AttendanceStatus.makeupScheduled,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (statusResult.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Make-up session scheduled')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(statusResult.errorOrNull ?? 'Failed to update status')),
                      );
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
          ),
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Schedule'),
        ),
      ],
    );
  }
}

