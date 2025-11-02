import 'package:flutter/material.dart';

class AppGradients {
  // Primary gradient (default): indigo → magenta
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6A85F1), // Indigo
      Color(0xFFB06AB3), // Magenta
    ],
  );
  
  // Alt gradient: cyan → blue
  static const LinearGradient alt = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C6FF), // Cyan
      Color(0xFF0072FF), // Blue
    ],
  );
  
  // Alt warm: amber → red
  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7971E), // Amber
      Color(0xFFFF512F), // Red
    ],
  );
  
  // Dark variants for dark mode
  static const LinearGradient primaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A5FB1), // Darker indigo
      Color(0xFF804A83), // Darker magenta
    ],
  );
  
  static const LinearGradient altDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0096BF), // Darker cyan
      Color(0xFF0052BF), // Darker blue
    ],
  );
  
  static const LinearGradient warmDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC7771E), // Darker amber
      Color(0xFFCF412F), // Darker red
    ],
  );
}

/// Animated gradient background with slow parallax shift
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final LinearGradient gradient;
  final Duration duration;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.gradient = AppGradients.primary,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Alignment>(
      tween: Tween<Alignment>(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: widget.duration,
      curve: Curves.easeInOut,
      onEnd: () {
        // Reverse animation
        setState(() {});
      },
      builder: (context, alignment, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignment,
              end: Alignment(
                -alignment.x * 0.8,
                -alignment.y * 0.8,
              ),
              colors: widget.gradient.colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

