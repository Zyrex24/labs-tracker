import 'package:flutter/material.dart';
import 'glass.dart';
import '../theme/glass_theme.dart';

enum ChipStyle {
  notReady,
  due,
  attended,
  missed,
  sickPending,
  sickSubmitted,
  makeup,
}

/// Glass chip for status badges
class GlassChip extends StatelessWidget {
  final String label;
  final ChipStyle style;
  final IconData? icon;
  final bool compact;
  
  const GlassChip({
    super.key,
    required this.label,
    required this.style,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (fillColor, borderColor) = _getColors(style);
    
    if (compact) {
      // Compact mode: icon only
      return Container(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(GlassTheme.radiusSmall),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon ?? Icons.circle,
          size: 16,
          color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
        ),
      );
    }
    
    return Glass(
      radius: GlassTheme.radiusSmall,
      blur: GlassTheme.blurLight,
      opacity: 0,
      borderOpacity: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: fillColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GlassTheme.radiusSmall),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GlassTheme.caption.copyWith(
                color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  (Color, Color) _getColors(ChipStyle style) {
    return switch (style) {
      ChipStyle.notReady => (GlassTheme.chipNotReadyFill, GlassTheme.chipNotReadyBorder),
      ChipStyle.due => (GlassTheme.chipDueFill, GlassTheme.chipDueBorder),
      ChipStyle.attended => (GlassTheme.chipAttendedFill, GlassTheme.chipAttendedBorder),
      ChipStyle.missed => (GlassTheme.chipMissedFill, GlassTheme.chipMissedBorder),
      ChipStyle.sickPending => (GlassTheme.chipSickPendingFill, GlassTheme.chipSickPendingBorder),
      ChipStyle.sickSubmitted => (GlassTheme.chipSickSubmittedFill, GlassTheme.chipSickSubmittedBorder),
      ChipStyle.makeup => (GlassTheme.chipMakeupFill, GlassTheme.chipMakeupBorder),
    };
  }
}

