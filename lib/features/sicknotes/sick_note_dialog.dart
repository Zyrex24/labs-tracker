import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/glass/glass_dialog.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repos/providers.dart';
import '../../domain/attendance_state.dart';

class SickNoteDialog extends HookConsumerWidget {
  final LabSession session;

  const SickNoteDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilePath = useState<String?>(null);
    final isLoading = useState(false);
    final imagePicker = useMemoized(() => ImagePicker());

    return GlassDialog(
      title: 'Submit Sick Note',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Attach a photo or PDF of your sick note',
            style: GlassTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(GlassTheme.textOpacityBody),
            ),
          ),
          const SizedBox(height: 24),
          
          // Camera button
          OutlinedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final image = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      selectedFilePath.value = image.path;
                    }
                  },
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          
          // Gallery button
          OutlinedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final image = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      selectedFilePath.value = image.path;
                    }
                  },
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          
          // File picker button
          OutlinedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null) {
                      selectedFilePath.value = result.files.single.path;
                    }
                  },
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Choose PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          
          if (selectedFilePath.value != null) ...[
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
                      'File selected',
                      style: GlassTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => selectedFilePath.value = null,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(GlassTheme.iconOpacityInactive),
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
          onPressed: (isLoading.value || selectedFilePath.value == null)
              ? null
              : () async {
                  isLoading.value = true;
                  
                  // Create sick note
                  final sickNotesRepo = ref.read(sickNotesRepoProvider);
                  final result = await sickNotesRepo.createSickNote(
                    labSessionId: session.id,
                    sourceFilePath: selectedFilePath.value!,
                  );
                  
                  if (result.isFailure) {
                    if (context.mounted) {
                      isLoading.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.errorOrNull ?? 'Failed to submit')),
                      );
                    }
                    return;
                  }
                  
                  // Update attendance to sick_submitted
                  final attendanceRepo = ref.read(attendanceRepoProvider);
                  final attendanceResult = await attendanceRepo.markSickSubmitted(session.id);
                  
                  if (attendanceResult.isFailure) {
                    if (context.mounted) {
                      isLoading.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(attendanceResult.errorOrNull ?? 'Failed to update status')),
                      );
                    }
                    return;
                  }
                  
                  // Auto-create makeup session
                  final sessionsRepo = ref.read(sessionsRepoProvider);
                  final makeupResult = await sessionsRepo.createSession(
                    subjectId: session.subjectId,
                    plannedAt: DateTime.now().add(const Duration(days: 7)), // Placeholder date
                    type: SessionType.makeup,
                    location: session.location,
                    slot: session.slot,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (makeupResult.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sick note submitted. Make-up session created.'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sick note submitted, but failed to create make-up session'),
                        ),
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
              : const Text('Submit'),
        ),
      ],
    );
  }
}

