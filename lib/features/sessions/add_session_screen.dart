import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/glass/glass_scaffold.dart';
import '../../app/glass/glass_card.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';

class AddSessionScreen extends HookConsumerWidget {
  final Subject subject;

  const AddSessionScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final selectedTime = useState(TimeOfDay.now());
    final locationController = useTextEditingController();
    final slotController = useTextEditingController();
    final isLoading = useState(false);

    return GlassScaffold(
      title: 'Add Session',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
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
                      color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            GlassCard(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate.value = date;
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: GlassTheme.caption.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
                          style: GlassTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Time picker
            GlassCard(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime.value,
                );
                if (time != null) {
                  selectedTime.value = time;
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: GlassTheme.caption.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedTime.value.format(context),
                          style: GlassTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Location
            GlassCard(
              child: TextField(
                controller: locationController,
                style: TextStyle(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                ),
                decoration: InputDecoration(
                  labelText: 'Location (optional)',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                  ),
                  hintText: 'e.g., Lab 3',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Slot
            GlassCard(
              child: TextField(
                controller: slotController,
                style: TextStyle(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                ),
                decoration: InputDecoration(
                  labelText: 'Slot (optional)',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                  ),
                  hintText: 'e.g., Morning',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Add button
            ElevatedButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      isLoading.value = true;
                      
                      final dateTime = DateTime(
                        selectedDate.value.year,
                        selectedDate.value.month,
                        selectedDate.value.day,
                        selectedTime.value.hour,
                        selectedTime.value.minute,
                      );
                      
                      final repo = ref.read(sessionsRepoProvider);
                      final result = await repo.createSession(
                        subjectId: subject.id,
                        plannedAt: dateTime,
                        location: locationController.text.isEmpty ? null : locationController.text,
                        slot: slotController.text.isEmpty ? null : slotController.text,
                        type: SessionType.regular,
                      );
                      
                      if (context.mounted) {
                        if (result.isSuccess) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session added successfully')),
                          );
                        } else {
                          isLoading.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.errorOrNull ?? 'Failed to add session')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add Session'),
            ),
          ],
        ),
      ),
    );
  }
}

