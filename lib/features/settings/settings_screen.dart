import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/repos/providers.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowHours = ref.watch(notificationWindowHoursProvider);

    return GlassScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification window
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_rounded,
                        color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notification Window',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sessions become "Due" within ± $windowHours hours',
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: windowHours.toDouble(),
                          min: 1,
                          max: 12,
                          divisions: 11,
                          label: '$windowHours hours',
                          activeColor: Colors.white.withOpacity(0.8),
                          inactiveColor: Colors.white.withOpacity(0.3),
                          onChanged: (value) {
                            ref.read(notificationWindowHoursProvider.notifier).state = value.toInt();
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$windowHours h',
                          style: GlassTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Backup & Restore
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.backup_rounded,
                        color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Backup & Restore',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Export Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restore feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Import Backup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data Management
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage_rounded,
                        color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Data Management',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sample data feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.science_rounded),
                    label: const Text('Load Sample Data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.25),
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E1E),
                          title: const Text(
                            'Reset All Data',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'This will delete all subjects, sessions, attendance records, sick notes, and exams. This action cannot be undone.',
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
                                'Reset',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reset feature coming soon')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Reset All Data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'About',
                        style: GlassTheme.titleMedium.copyWith(
                          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Labs Tracker v1.0.0',
                    style: GlassTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '100% offline lab attendance tracker',
                    style: GlassTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

