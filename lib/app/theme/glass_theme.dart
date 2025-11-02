import 'package:flutter/material.dart';

class GlassTheme {
  // Blur values
  static const double blurLight = 12.0;
  static const double blurMedium = 16.0;
  static const double blurHeavy = 24.0;
  
  // Border radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  
  // Opacities for glass surfaces
  static const double opacityElevation0 = 0.08;
  static const double opacityElevation1 = 0.12;
  static const double opacityElevation2 = 0.16;
  static const double opacityElevation3 = 0.20;
  
  // Opacities for chips/badges
  static const double opacityChip = 0.08;
  
  // Border opacities
  static const double borderOpacityLight = 0.24;
  static const double borderOpacityMedium = 0.35;
  static const double borderOpacityHeavy = 0.45;
  
  // Text opacities on glass
  static const double textOpacityTitle = 0.92;
  static const double textOpacityBody = 0.82;
  static const double textOpacityMeta = 0.64;
  static const double textOpacityDisabled = 0.38;
  
  // Icon opacities
  static const double iconOpacityActive = 0.90;
  static const double iconOpacityInactive = 0.72;
  
  // Shadow for elevation
  static BoxShadow shadowElevation0 = BoxShadow(
    color: Colors.black.withOpacity(0.10),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow shadowElevation1 = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
  
  static BoxShadow shadowElevation2 = BoxShadow(
    color: Colors.black.withOpacity(0.20),
    blurRadius: 18,
    offset: const Offset(0, 10),
  );
  
  static BoxShadow shadowElevation3 = BoxShadow(
    color: Colors.black.withOpacity(0.25),
    blurRadius: 24,
    offset: const Offset(0, 14),
  );
  
  // Status chip colors (translucent fills with colored borders)
  static const Color chipNotReadyFill = Color(0x0FFFFFFF);
  static const Color chipNotReadyBorder = Color(0x3DFFFFFF);
  
  static const Color chipDueFill = Color(0x1AFFFFFF);
  static const Color chipDueBorder = Color(0x99A5B4FC); // Indigo-300 @0.6
  
  static const Color chipAttendedFill = Color(0x2E4CD964); // Green @0.18
  static const Color chipAttendedBorder = Color(0xA64CD964); // Green @0.65
  
  static const Color chipMissedFill = Color(0x2EFF3B30); // Red @0.18
  static const Color chipMissedBorder = Color(0xA6FF3B30); // Red @0.65
  
  static const Color chipSickPendingFill = Color(0x2EFF9F0A); // Orange @0.18
  static const Color chipSickPendingBorder = Color(0xA6FF9F0A); // Orange @0.65
  
  static const Color chipSickSubmittedFill = Color(0x2E5856D6); // Purple @0.18
  static const Color chipSickSubmittedBorder = Color(0xA65856D6); // Purple @0.65
  
  static const Color chipMakeupFill = Color(0x2E007AFF); // Blue @0.18
  static const Color chipMakeupBorder = Color(0xA6007AFF); // Blue @0.65
  
  // Typography
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );
}

