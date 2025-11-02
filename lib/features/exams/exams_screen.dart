import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/theme/glass_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import 'add_exam_dialog.dart';

class ExamsScreen extends HookConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(watchAllExamsProvider);
    final subjectsAsync = ref.watch(watchAllSubjectsProvider);

    return GlassScaffold(
      title: 'Exams',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.25),
            builder: (context) => const AddExamDialog(),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
        ),
      ),
      body: examsAsync.when(
        data: (exams) {
          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exams scheduled',
                    style: GlassTheme.titleMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add an exam',
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort exams by date
          final sortedExams = exams.toList()
            ..sort((a, b) => a.examDate.compareTo(b.examDate));

          return subjectsAsync.when(
            data: (subjects) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sortedExams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exam = sortedExams[index];
                  final subject = subjects.firstWhere(
                    (s) => s.id == exam.subjectId,
                    orElse: () => Subject(
                      id: '',
                      name: 'Unknown Subject',
                      code: '',
                      labsRequired: 0,
                    ),
                  );
                  return _ExamCard(exam: exam, subject: subject);
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
                'Error loading subjects: $error',
                style: TextStyle(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                ),
              ),
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

class _ExamCard extends HookConsumerWidget {
  final Exam exam;
  final Subject subject;

  const _ExamCard({
    required this.exam,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examDate = AppDateUtils.fromIso8601(exam.examDate);
    final isRegistered = exam.registered == 1;

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
                      subject.name,
                      style: GlassTheme.titleMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.code,
                      style: GlassTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.25),
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text(
                        'Delete Exam',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this exam?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    final repo = ref.read(examsRepoProvider);
                    final result = await repo.deleteExam(exam.id);
                    if (context.mounted) {
                      if (result.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exam deleted')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.errorOrNull ?? 'Failed to delete')),
                        );
                      }
                    }
                  }
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
              ),
              const SizedBox(width: 8),
              Text(
                AppDateUtils.formatDate(examDate),
                style: GlassTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
              ),
              const SizedBox(width: 8),
              Text(
                AppDateUtils.formatTime(examDate),
                style: GlassTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Registration toggle
          GestureDetector(
            onTap: () async {
              final repo = ref.read(examsRepoProvider);
              final result = await repo.updateExam(
                exam.id,
                registered: !isRegistered,
              );
              if (context.mounted && result.isFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.errorOrNull ?? 'Failed to update')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRegistered
                    ? const Color(0x2E4CD964)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRegistered
                      ? const Color(0xA64CD964)
                      : Colors.white.withOpacity(0.24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isRegistered ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRegistered ? 'Registered' : 'Not Registered',
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

