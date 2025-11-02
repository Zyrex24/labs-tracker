import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_card.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/repos/providers.dart';
import '../../data/db/app_database.dart';
import 'subject_detail_screen.dart';
import 'widgets/add_subject_dialog.dart';
import 'widgets/subject_card.dart';

class SubjectsScreen extends HookConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(watchAllSubjectsProvider);

    return GlassScaffold(
      title: 'Subjects',
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return _EmptyState(
              onAddSubject: () => _showAddSubjectDialog(context, ref),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final subject = subjects[index];
                      return SubjectCard(
                        subject: subject,
                        onTap: () => _navigateToSubjectDetail(context, subject),
                      );
                    },
                    childCount: subjects.length,
                  ),
                ),
              ),
            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context, ref),
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => const AddSubjectDialog(),
    );
  }

  void _navigateToSubjectDetail(BuildContext context, Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubjectDetailScreen(subject: subject),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddSubject;

  const _EmptyState({required this.onAddSubject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No subjects yet',
            style: GlassTheme.titleMedium.copyWith(
              color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first subject to start tracking labs',
            style: GlassTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAddSubject,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

