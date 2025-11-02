import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/gradients.dart';
import '../theme/glass_theme.dart';
import 'glass.dart';

/// Scaffold with gradient background and glass app bar
class GlassScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final LinearGradient gradient;
  final bool showAppBar;
  
  const GlassScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.gradient = AppGradients.primary,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: GlassTheme.blurMedium,
                    sigmaY: GlassTheme.blurMedium,
                  ),
                  child: AppBar(
                    backgroundColor: Colors.white.withOpacity(GlassTheme.opacityElevation1),
                    elevation: 0,
                    title: title != null
                        ? Text(
                            title!,
                            style: GlassTheme.titleMedium.copyWith(
                              color: Colors.white.withOpacity(GlassTheme.textOpacityTitle),
                            ),
                          )
                        : null,
                    iconTheme: IconThemeData(
                      color: Colors.white.withOpacity(GlassTheme.iconOpacityActive),
                    ),
                    actions: actions,
                  ),
                ),
              ),
            )
          : null,
      body: AnimatedGradientBackground(
        gradient: gradient,
        child: SafeArea(
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Glass bottom navigation bar
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassBottomNavItem> items;
  
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassTheme.blurMedium,
          sigmaY: GlassTheme.blurMedium,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(GlassTheme.opacityElevation1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(GlassTheme.borderOpacityLight),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) => _NavItem(
                    item: items[index],
                    isSelected: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomNavItem {
  final IconData icon;
  final String label;
  
  const GlassBottomNavItem({
    required this.icon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final GlassBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: Colors.white.withOpacity(
                isSelected
                    ? GlassTheme.iconOpacityActive
                    : GlassTheme.iconOpacityInactive,
              ),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GlassTheme.caption.copyWith(
                color: Colors.white.withOpacity(
                  isSelected
                      ? GlassTheme.textOpacityTitle
                      : GlassTheme.textOpacityMeta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

