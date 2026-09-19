import 'dart:io';

import 'package:flutter/material.dart';

import '../data/herbal_data.dart';
import '../theme/app_theme.dart';
import 'plant_thumb.dart';

/// Kartu tanaman untuk grid di Beranda dan Koleksi.
class PlantCard extends StatelessWidget {
  final HerbalPlant plant;
  final VoidCallback onTap;
  final File? photo;
  final bool saved;
  final String? footnote; // mis. "Dipindai 19 Sep"
  final VoidCallback? onLongPress;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.photo,
    this.saved = false,
    this.footnote,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PlantThumb(plant: plant, file: photo),
                        ),
                      ),
                      if (saved)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              size: 16,
                              color: AppColors.forest,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  footnote ?? plant.latin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle:
                            footnote == null ? FontStyle.italic : FontStyle.normal,
                      ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
