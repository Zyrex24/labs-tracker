import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';

class SubjectDetailScreen extends HookConsumerWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(watchSessionsBySubjectProvider(subject.id));

    return GlassScaffold(
      title: subject.name,
      body: CustomScrollView(
        slivers: [
          // Subject info header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.code,
                      style: GlassTheme.titleLarge.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Labs Required: ${subject.labsRequired}',
                      style: GlassTheme.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Sessions list
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No sessions yet',
                          style: GlassTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = sessions[index];
                      return GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session ${index + 1}',
                              style: GlassTheme.titleSmall.copyWith(
                                color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type: ${session.type}',
                              style: GlassTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                              ),
                            ),
                            if (session.location != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Location: ${session.location}',
                                style: GlassTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    childCount: sessions.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

