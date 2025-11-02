import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_dialog.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';

class AddExamDialog extends HookConsumerWidget {
  const AddExamDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(watchAllSubjectsProvider);
    final selectedSubject = useState<Subject?>(null);
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);
    final isLoading = useState(false);

    return GlassDialog(
      title: 'Add Exam',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subject dropdown
          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return Text(
                  'No subjects available. Please add subjects first.',
                  style: GlassTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Subject>(
                    value: selectedSubject.value,
                    hint: Text(
                      'Select Subject',
                      style: TextStyle(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                      ),
                    ),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                    ),
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text('${subject.code} - ${subject.name}'),
                      );
                    }).toList(),
                    onChanged: isLoading.value
                        ? null
                        : (subject) {
                            selectedSubject.value = subject;
                          },
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            error: (error, stack) => Text(
              'Error loading subjects: $error',
              style: TextStyle(
                color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
          onPressed: (isLoading.value ||
                  selectedSubject.value == null ||
                  selectedDate.value == null ||
                  selectedTime.value == null)
              ? null
              : () async {
                  isLoading.value = true;

                  // Combine date and time
                  final examDateTime = DateTime(
                    selectedDate.value!.year,
                    selectedDate.value!.month,
                    selectedDate.value!.day,
                    selectedTime.value!.hour,
                    selectedTime.value!.minute,
                  );

                  // Create exam
                  final repo = ref.read(examsRepoProvider);
                  final result = await repo.createExam(
                    subjectId: selectedSubject.value!.id,
                    examDate: examDateTime,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (result.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exam added')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.errorOrNull ?? 'Failed to add exam')),
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
              : const Text('Add'),
        ),
      ],
    );
  }
}

