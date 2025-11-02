import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/glass_theme.dart';

/// Base glass container with backdrop blur and translucent fill
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final EdgeInsetsGeometry padding;
  final BoxShadow? shadow;
  final bool showInnerHighlight;
  final Color? color;
  
  const Glass({
    super.key,
    required this.child,
    this.radius = GlassTheme.radiusLarge,
    this.blur = GlassTheme.blurMedium,
    this.opacity = GlassTheme.opacityElevation1,
    this.borderOpacity = GlassTheme.borderOpacityMedium,
    this.padding = const EdgeInsets.all(12),
    this.shadow,
    this.showInnerHighlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
            boxShadow: shadow != null ? [shadow!] : null,
          ),
          child: showInnerHighlight
              ? Stack(
                  children: [
                    // Inner highlight gradient
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(radius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: padding,
                      child: child,
                    ),
                  ],
                )
              : Padding(
                  padding: padding,
                  child: child,
                ),
        ),
      ),
    );
  }
}

/// Glass with elevation variants
class GlassElevated extends StatelessWidget {
  final Widget child;
  final int elevation; // 0, 1, 2, or 3
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool showInnerHighlight;
  
  const GlassElevated({
    super.key,
    required this.child,
    this.elevation = 1,
    this.radius = GlassTheme.radiusLarge,
    this.padding = const EdgeInsets.all(12),
    this.showInnerHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = switch (elevation) {
      0 => GlassTheme.opacityElevation0,
      1 => GlassTheme.opacityElevation1,
      2 => GlassTheme.opacityElevation2,
      _ => GlassTheme.opacityElevation3,
    };
    
    final shadow = switch (elevation) {
      0 => GlassTheme.shadowElevation0,
      1 => GlassTheme.shadowElevation1,
      2 => GlassTheme.shadowElevation2,
      _ => GlassTheme.shadowElevation3,
    };
    
    return Glass(
      radius: radius,
      opacity: opacity,
      shadow: shadow,
      padding: padding,
      showInnerHighlight: showInnerHighlight,
      child: child,
    );
  }
}

