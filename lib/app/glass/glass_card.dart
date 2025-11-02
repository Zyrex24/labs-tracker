import 'package:flutter/material.dart';
import 'glass.dart';
import '../theme/glass_theme.dart';

/// Glass card for list items and content containers
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final int elevation;
  
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassElevated(
      elevation: elevation,
      padding: padding,
      showInnerHighlight: true,
      child: child,
    );
    
    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(GlassTheme.radiusLarge),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: card,
          ),
        ),
      );
    }
    
    return Padding(
      padding: margin,
      child: card,
    );
  }
}

