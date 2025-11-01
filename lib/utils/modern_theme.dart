import 'package:flutter/material.dart';

class ModernTheme {
  // Modern Color Palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1E40AF);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color secondaryPurpleDark = Color(0xFF6D28D9);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFD97706);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenDark = Color(0xFF059669);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerRedDark = Color(0xFFDC2626);
  static const Color infoCyan = Color(0xFF06B6D4);
  static const Color infoCyanDark = Color(0xFF0891B2);
  
  // Premium Orange
  static const Color premiumOrange = Color(0xFFFF6B35);
  static const Color premiumOrangeDark = Color(0xFFF7931E);
  
  // Neutrals
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color hoverLight = Color(0xFFF1F5F9);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient practiceGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient resultsGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background Gradients (Subtle)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueBackgroundGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Enhanced Shadows (Elevation System)
  static List<BoxShadow> elevation1() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  static List<BoxShadow> elevation2() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  static List<BoxShadow> elevation3() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
  
  static List<BoxShadow> elevation4() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 30,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ];
  }
  
  // Colored Shadows
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.5),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }
  
  // Card Decorations
  static BoxDecoration modernCard({
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cardWhite,
      borderRadius: BorderRadius.circular(20),
      border: border ?? Border.all(color: borderLight, width: 1),
      boxShadow: shadows ?? elevation2(),
    );
  }
  
  static BoxDecoration gradientCard({
    required Gradient gradient,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: shadows ?? elevation3(),
    );
  }
  
  // Glass Morphism Effect
  static BoxDecoration glassMorphism({
    Color? color,
    double blur = 10,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // Button Styles
  static ButtonStyle primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }
  
  static ButtonStyle gradientButton({Color? shadowColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    );
  }
  
  // Shimmer Loading Effect Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  
  // Risk Level Colors (Enhanced)
  static Color getRiskColor(double risk) {
    if (risk < 0.4) return successGreen;
    if (risk < 0.7) return accentAmber;
    return dangerRed;
  }
  
  static LinearGradient getRiskGradient(double risk) {
    if (risk < 0.4) return successGradient;
    if (risk < 0.7) return practiceGradient;
    return dangerGradient;
  }
  
  // Icon Background
  static BoxDecoration iconBackground(Color color, {bool gradient = false}) {
    return BoxDecoration(
      color: gradient ? null : color.withOpacity(0.1),
      gradient: gradient ? LinearGradient(
        colors: [color, color.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ) : null,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
