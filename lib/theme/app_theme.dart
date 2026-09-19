import 'package:flutter/material.dart';

/// Palet botanical HerbaScan.
/// Hijau hutan untuk aksi utama, sage untuk panel, mint & krem untuk latar.
class AppColors {
  AppColors._();

  static const forest = Color(0xFF2F5D3A);
  static const sage = Color(0xFF7D9C5C);
  static const moss = Color(0xFF5B7F45); // panel hijau dengan teks putih (kontras ≥ 4.5)
  static const leaf = Color(0xFF3F8F4F);
  static const mint = Color(0xFFE4EEDC);
  static const cream = Color(0xFFF3F5EE);
  static const ink = Color(0xFF1F2A24);
  static const muted = Color(0xFF66736B);
  static const amber = Color(0xFFD9A441);
  static const amberSoft = Color(0xFFFBF1DB);
  static const danger = Color(0xFFC4573D);
  static const white = Colors.white;

  /// Bayangan lembut untuk kartu (alpha eksplisit agar aman di semua versi Flutter).
  static const shadow = Color(0x142F5D3A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.forest, secondary: AppColors.sage);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.muted,
        ),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
