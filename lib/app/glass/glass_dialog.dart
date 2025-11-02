import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass.dart';
import '../theme/glass_theme.dart';

/// Glass dialog with heavier blur and darker scrim
class GlassDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  
  const GlassDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Glass(
        radius: GlassTheme.radiusXLarge,
        blur: GlassTheme.blurHeavy,
        opacity: GlassTheme.opacityElevation2,
        shadow: GlassTheme.shadowElevation3,
        showInnerHighlight: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: GlassTheme.titleMedium.copyWith(
                  color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                ),
              ),
              const SizedBox(height: 16),
            ],
            content,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => GlassDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}

