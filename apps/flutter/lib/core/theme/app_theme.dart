import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  static const String fontFamily = 'Lato';
  static const String persianFontFamily = 'Vazirmatn';
  static const List<String> defaultFontFallbacks = [
    'Vazirmatn',
    'Lato',
    'NotoColorEmoji',
  ];

  static ThemeData get lightTheme => themeFor(null, isDark: false);
  static ThemeData get darkTheme => themeFor(null, isDark: true);

  static ThemeData themeFor(Locale? locale, {bool isDark = true}) {
    final isPersian =
        locale?.languageCode == 'fa' || locale?.languageCode == 'ar';
    final activeFont = isPersian ? persianFontFamily : fontFamily;
    final fallbackList = isPersian
        ? const ['Lato', 'NotoColorEmoji']
        : const ['Vazirmatn', 'NotoColorEmoji'];

    return isDark
        ? _buildDarkTheme(activeFont, fallbackList, isPersian)
        : _buildLightTheme(activeFont, fallbackList, isPersian);
  }

  static ThemeData _buildLightTheme(
      String activeFont, List<String> fallbackList, bool isPersian) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: activeFont,
      fontFamilyFallback: fallbackList,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Color(0xFF092B3B),
        secondary: AppColors.secondary,
        onSecondary: Color(0xFF092B3B),
        surface: Colors.white,
        error: Colors.red,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(Colors.black87,
          family: activeFont, fallbacks: fallbackList, isPersian: isPersian),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.grey,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.90),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.black87,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.86),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      tabBarTheme: _glassTabBarTheme(dark: false),
      navigationBarTheme: _glassNavigationBarTheme(dark: false),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black54,
      ),
      popupMenuTheme: _glassPopupMenuTheme(dark: false),
      snackBarTheme: _glassSnackBarTheme(dark: false),
      listTileTheme: _glassListTileTheme(dark: false),
      switchTheme: _glassSwitchTheme(dark: false),
      checkboxTheme: _glassCheckboxTheme(dark: false),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData _buildDarkTheme(
      String activeFont, List<String> fallbackList, bool isPersian) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: activeFont,
      fontFamilyFallback: fallbackList,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Color(0xFF092B3B),
        secondary: AppColors.secondary,
        onSecondary: Color(0xFF092B3B),
        surface: Color(0xFF143E50),
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF092B3B),
      textTheme: _buildTextTheme(Colors.white,
          family: activeFont, fallbacks: fallbackList, isPersian: isPersian),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.bottomGradientConnected,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          side: const BorderSide(color: Colors.white70, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white70,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white38,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1.0,
          ),
        ),
        color: const Color(0xFF0C2433).withValues(alpha: 0.58),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF09202E).withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1.2,
          ),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white70,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF09202E).withValues(alpha: 0.84),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.0,
          ),
        ),
      ),
      tabBarTheme: _glassTabBarTheme(dark: true),
      navigationBarTheme: _glassNavigationBarTheme(dark: true),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Color(0xFF61F2C2),
        unselectedItemColor: Colors.white60,
      ),
      popupMenuTheme: _glassPopupMenuTheme(dark: true),
      snackBarTheme: _glassSnackBarTheme(dark: true),
      listTileTheme: _glassListTileTheme(dark: true),
      switchTheme: _glassSwitchTheme(dark: true),
      checkboxTheme: _glassCheckboxTheme(dark: true),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TabBarThemeData _glassTabBarTheme({required bool dark}) {
    final accent = dark ? const Color(0xFF61F2C2) : AppColors.primary;
    return TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: accent.withValues(alpha: dark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accent.withValues(alpha: 0.34)),
      ),
      labelColor: dark ? Colors.white : AppColors.background,
      unselectedLabelColor: dark ? Colors.white60 : Colors.black54,
      overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.08)),
    );
  }

  static NavigationBarThemeData _glassNavigationBarTheme({required bool dark}) {
    final accent = dark ? const Color(0xFF61F2C2) : AppColors.primary;
    return NavigationBarThemeData(
      backgroundColor: dark
          ? const Color(0xFF0C2433).withValues(alpha: 0.72)
          : Colors.white.withValues(alpha: 0.72),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: accent.withValues(alpha: dark ? 0.20 : 0.14),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.08)),
    );
  }

  static PopupMenuThemeData _glassPopupMenuTheme({required bool dark}) {
    return PopupMenuThemeData(
      color: dark
          ? const Color(0xFF0B202D).withValues(alpha: 0.94)
          : Colors.white.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(
          color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.12),
        ),
      ),
    );
  }

  static SnackBarThemeData _glassSnackBarTheme({required bool dark}) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark
          ? const Color(0xFF102B3B).withValues(alpha: 0.96)
          : const Color(0xFF172B36).withValues(alpha: 0.96),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      contentTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.white,
        fontSize: 14.sp,
      ),
    );
  }

  static ListTileThemeData _glassListTileTheme({required bool dark}) {
    final accent = dark ? const Color(0xFF61F2C2) : AppColors.primary;
    return ListTileThemeData(
      selectedTileColor: accent.withValues(alpha: 0.14),
      selectedColor: accent,
      iconColor: dark ? Colors.white70 : Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      minVerticalPadding: 8,
    );
  }

  static SwitchThemeData _glassSwitchTheme({required bool dark}) {
    final accent = dark ? const Color(0xFF61F2C2) : AppColors.primary;
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return dark ? Colors.white70 : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accent.withValues(alpha: 0.62);
        }
        return (dark ? Colors.white : Colors.black).withValues(alpha: 0.14);
      }),
      trackOutlineColor: WidgetStatePropertyAll(
        (dark ? Colors.white : Colors.black).withValues(alpha: 0.18),
      ),
    );
  }

  static CheckboxThemeData _glassCheckboxTheme({required bool dark}) {
    final accent = dark ? const Color(0xFF61F2C2) : AppColors.primary;
    return CheckboxThemeData(
      checkColor: const WidgetStatePropertyAll(Colors.white),
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? accent : Colors.transparent),
      side: BorderSide(
        color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.42),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
    );
  }

  static TextTheme _buildTextTheme(Color defaultColor,
      {String family = fontFamily,
      List<String>? fallbacks,
      bool isPersian = false}) {
    final effectiveFallbacks = fallbacks ?? defaultFontFallbacks;
    final spacing = isPersian ? 0.0 : null;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing ?? -0.25,
        color: defaultColor,
      ),
      displayMedium: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      displaySmall: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 32.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 28.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing,
        color: defaultColor,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 0.15,
        color: defaultColor,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 0.1,
        color: defaultColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing ?? 0.5,
        color: defaultColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing ?? 0.25,
        color: defaultColor,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: spacing ?? 0.4,
        color: defaultColor,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 0.1,
        color: defaultColor,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 0.5,
        color: defaultColor,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontFamilyFallback: effectiveFallbacks,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: spacing ?? 0.5,
        color: defaultColor,
      ),
    );
  }
}
