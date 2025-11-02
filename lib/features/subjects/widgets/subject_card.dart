import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../app/glass/glass_card.dart';
import '../../../app/theme/glass_theme.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repos/providers.dart';

class SubjectCard extends HookConsumerWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get stats for this subject
    final attendanceRepo = ref.watch(attendanceRepoProvider);

    return GlassCard(
      onTap: onTap,
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
                      style: GlassTheme.titleSmall.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.code,
                      style: GlassTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          FutureBuilder(
            future: attendanceRepo.calculateSubjectStats(subject.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final result = snapshot.data!;
              if (result.isFailure) {
                return const SizedBox.shrink();
              }

              final stats = result.valueOrNull!;
              final completed = stats.attended + stats.makeupAttended;
              final remaining = subject.labsRequired > completed 
                  ? subject.labsRequired - completed 
                  : 0;

              return Row(
                children: [
                  _StatItem(
                    label: 'Attended',
                    value: '${stats.attended}',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    label: 'Required',
                    value: '${subject.labsRequired}',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    label: 'Remaining',
                    value: '$remaining',
                    icon: Icons.pending_outlined,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GlassTheme.caption.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GlassTheme.titleMedium.copyWith(
              color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
            ),
          ),
        ],
      ),
    );
  }
}

