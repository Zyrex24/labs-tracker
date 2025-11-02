import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../app/glass/glass_dialog.dart';
import '../../../app/theme/glass_theme.dart';
import '../../../data/repos/providers.dart';

class AddSubjectDialog extends HookConsumerWidget {
  const AddSubjectDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final codeController = useTextEditingController();
    final labsRequiredController = useTextEditingController(text: '12');
    final isLoading = useState(false);

    return GlassDialog(
      title: 'Add Subject',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlassTextField(
            controller: nameController,
            label: 'Subject Name',
            hint: 'e.g., Computer Networks',
          ),
          const SizedBox(height: 16),
          _GlassTextField(
            controller: codeController,
            label: 'Subject Code',
            hint: 'e.g., CS301',
          ),
          const SizedBox(height: 16),
          _GlassTextField(
            controller: labsRequiredController,
            label: 'Labs Required',
            hint: '12',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          onPressed: isLoading.value
              ? null
              : () async {
                  if (nameController.text.isEmpty ||
                      codeController.text.isEmpty ||
                      labsRequiredController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  isLoading.value = true;
                  final repo = ref.read(subjectsRepoProvider);
                  final result = await repo.createSubject(
                    name: nameController.text,
                    code: codeController.text,
                    labsRequired: int.parse(labsRequiredController.text),
                  );

                  if (context.mounted) {
                    if (result.isSuccess) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subject added successfully')),
                      );
                    } else {
                      isLoading.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.errorOrNull ?? 'Failed to add subject')),
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

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GlassTheme.bodyMedium.copyWith(
            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(GlassTheme.textOpacityMeta),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

