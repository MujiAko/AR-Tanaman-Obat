import 'dart:io';

import 'package:flutter/material.dart';

import '../data/herbal_data.dart';
import '../theme/app_theme.dart';

/// Menampilkan foto pindaian pengguna, atau foto aset tanaman, atau ikon daun
/// bila keduanya tidak tersedia.
class PlantThumb extends StatelessWidget {
  final HerbalPlant plant;
  final File? file;
  final BoxFit fit;

  const PlantThumb({
    super.key,
    required this.plant,
    this.file,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final f = file;
    if (f != null) {
      return Image.file(
        f,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.asset(
      plant.assetPath,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, Color(0xFFC9DCB8)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 44, color: AppColors.sage),
      ),
    );
  }
}
