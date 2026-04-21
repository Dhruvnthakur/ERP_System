// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

// ── Warm Brown Palette (Light Theme) ─────────────────────────────────────────
// #291C0E  dark espresso   → primary text / headings
// #6E473B  warm mahogany   → AppBar / sidebar / primary surface
// #A78D78  sandy leather   → accent / buttons / highlights
// #BEB5A9  warm beige      → muted text helper
// #E1D4C2  cream parchment → scaffold background
// #FFFFFF  white           → card / input surfaces

class AppTheme {
  static const Color espresso  = Color(0xFF291C0E);
  static const Color mahogany  = Color(0xFF6E473B);
  static const Color leather   = Color(0xFFA78D78);
  static const Color beige     = Color(0xFFBEB5A9);
  static const Color parchment = Color(0xFFE1D4C2);
  static const Color white     = Color(0xFFFFFFFF);

  // Semantic aliases — keep old names so all screens compile without changes
  static const Color primary    = mahogany;
  static const Color secondary  = Color(0xFFF5EDE3);
  static const Color accent     = leather;
  static const Color accentLight= Color(0xFFCBB89E);
  static const Color gold       = Color(0xFFC49A6C);
  static const Color warmGrey   = Color(0xFF7A6A5A);
  static const Color cream      = espresso;
  static const Color cardDark   = white;
  static const Color surfaceDark= Color(0xFFF5EDE3);
  static const Color bgDark     = parchment;

  // Inline-color replacement tokens
  static const Color border       = Color(0xFFD8C8B5);
  static const Color borderStrong = leather;
  static const Color textMuted    = Color(0xFF7A6A5A);
  static const Color textFaint    = Color(0xFFAA9888);
  static const Color pillBg       = Color(0xFFF0E6D8);
  static const Color iconBg       = Color(0xFFEBDECF);

  // Status colours
  static const Color success = Color(0xFF2E7D52);
  static const Color warning = Color(0xFFB06820);
  static const Color danger  = Color(0xFFC0392B);
  static const Color info    = Color(0xFF5C7A9A);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: mahogany,
    scaffoldBackgroundColor: parchment,
    colorScheme: const ColorScheme.light(
      primary:   leather,
      secondary: beige,
      surface:   white,
      onPrimary: white,
      onSurface: espresso,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: mahogany,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: parchment, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.4),
      iconTheme: IconThemeData(color: parchment),
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mahogany,
        foregroundColor: parchment,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: border, width: 1.2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: leather, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: danger, width: 1.2)),
      labelStyle: const TextStyle(color: warmGrey),
      hintStyle:  const TextStyle(color: textFaint),
      prefixIconColor: leather,
    ),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(color: espresso, fontWeight: FontWeight.w800, fontSize: 28),
      headlineMedium: TextStyle(color: espresso, fontWeight: FontWeight.w700, fontSize: 22),
      titleLarge:     TextStyle(color: espresso, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium:    TextStyle(color: warmGrey, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge:      TextStyle(color: warmGrey, fontSize: 15),
      bodyMedium:     TextStyle(color: textMuted, fontSize: 13),
    ),
    chipTheme: ChipThemeData(
      color: WidgetStateProperty.all(pillBg),
      selectedColor: leather,
      labelStyle: const TextStyle(color: espresso),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: mahogany,
      selectedIconTheme:   IconThemeData(color: parchment),
      unselectedIconTheme: IconThemeData(color: Color(0xFFB89880)),
      selectedLabelTextStyle:   TextStyle(color: parchment, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFFB89880)),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: parchment,
      labelColor: parchment,
      unselectedLabelColor: Color(0xFFB89880),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: mahogany,
      selectedItemColor: parchment,
      unselectedItemColor: Color(0xFFB89880),
    ),
    dividerColor: border,
    dialogTheme: DialogThemeData(
      backgroundColor: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border),
      ),
    ),
  );
}

class AppColors {
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':       return AppTheme.success;
      case 'low_stock':      return AppTheme.warning;
      case 'manufacturing':  return AppTheme.info;
      case 'pending':        return AppTheme.warning;
      case 'processing':     return AppTheme.info;
      case 'shipped':        return AppTheme.leather;
      case 'delivered':      return AppTheme.success;
      case 'cancelled':      return AppTheme.danger;
      case 'cutting':        return AppTheme.warning;
      case 'stitching':      return AppTheme.gold;
      case 'finishing':      return AppTheme.info;
      case 'quality_check':  return AppTheme.leather;
      case 'completed':      return AppTheme.success;
      default:               return AppTheme.warmGrey;
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':      return 'In Stock';
      case 'low_stock':     return 'Low Stock';
      case 'manufacturing': return 'Manufacturing';
      case 'pending':       return 'Pending';
      case 'processing':    return 'Processing';
      case 'shipped':       return 'Shipped';
      case 'delivered':     return 'Delivered';
      case 'cancelled':     return 'Cancelled';
      case 'cutting':       return 'Cutting';
      case 'stitching':     return 'Stitching';
      case 'finishing':     return 'Finishing';
      case 'quality_check': return 'Quality Check';
      case 'completed':     return 'Completed';
      default:              return status;
    }
  }
}
