import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// AppTheme builds the official Academia Forense Material 3 Theme (§5.1)
class ForensicTheme {
  ForensicTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: ForensicColors.forestGreenPrimary,
      onPrimary: Colors.white,
      primaryContainer: ForensicColors.greenLight,
      onPrimaryContainer: ForensicColors.forestGreenDark,
      secondary: ForensicColors.greenSecondary,
      onSecondary: Colors.white,
      surface: ForensicColors.surface,
      onSurface: ForensicColors.textPrimary,
      surfaceContainerHighest: ForensicColors.softField,
      onSurfaceVariant: ForensicColors.textSecondary,
      outline: ForensicColors.borders,
      error: ForensicColors.error,
      onError: Colors.white,
      errorContainer: ForensicColors.errorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ForensicColors.background,
      fontFamily: ForensicTypography.fontFamilySans,
      appBarTheme: const AppBarTheme(
        backgroundColor: ForensicColors.surface,
        foregroundColor: ForensicColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1.0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: ForensicTypography.sectionTitle,
        iconTheme: IconThemeData(color: ForensicColors.forestGreenDark),
      ),
      dividerTheme: const DividerThemeData(
        color: ForensicColors.borders,
        thickness: 1.0,
        space: 1.0,
      ),
      cardTheme: CardTheme(
        color: ForensicColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: ForensicColors.borders, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ForensicColors.forestGreenPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48), // 48dp touch target
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ForensicColors.forestGreenPrimary,
          minimumSize: const Size(88, 48), // 48dp touch target
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: ForensicColors.forestGreenPrimary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ForensicColors.surface,
        indicatorColor: ForensicColors.greenLight,
        elevation: 3.0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ForensicColors.forestGreenDark,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: ForensicColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: ForensicColors.forestGreenDark,
              size: 24,
            );
          }
          return const IconThemeData(
            color: ForensicColors.textSecondary,
            size: 24,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: ForensicColors.surface,
        indicatorColor: ForensicColors.greenLight,
        selectedIconTheme: const IconThemeData(
          color: ForensicColors.forestGreenDark,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: ForensicColors.textSecondary,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ForensicColors.forestGreenDark,
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: ForensicColors.textSecondary,
        ),
      ),
    );
  }
}
