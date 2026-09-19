import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/collection_controller.dart';
import '../data/herbal_data.dart';
import '../theme/app_theme.dart';
import '../widget/plant_thumb.dart';

/// Page 3 — Detail Tanaman Obat (Herbal Monograph & Khasiat)
///
/// Dibuka dari Beranda, hasil pindai, atau Koleksi. [scanImage] dan [confidence]
/// hanya terisi bila dibuka dari hasil pemindaian / koleksi berfoto.
class PlantDetailPage extends StatelessWidget {
  final HerbalPlant plant;
  final File? scanImage;
  final double? confidence;

  const PlantDetailPage({
    super.key,
    required this.plant,
    this.scanImage,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasConfidence = confidence != null && confidence! > 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(plant: plant, photo: scanImage),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          plant.latin,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(
                              icon: Icons.category_rounded,
                              text: 'Kategori ${plant.category}',
                            ),
                            if (hasConfidence)
                              _Pill(
                                icon: Icons.verified_rounded,
                                text:
                                    'Keyakinan ${(confidence! * 100).toStringAsFixed(1)}%',
                                strong: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(plant.description, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 26),
                        Text('Khasiat tradisional',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        for (final b in plant.benefits)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.check_circle_rounded,
                                      size: 20, color: AppColors.leaf),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: AppColors.ink),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text('Cara pengolahan', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(plant.howTo,
                              style: theme.textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 22),
                        _CautionBox(items: plant.cautions),
                        const SizedBox(height: 14),
                        Text(
                          'Informasi ini bersifat edukatif dan berasal dari penggunaan tradisional. '
                          'Bukan pengganti diagnosis atau saran dokter. Hasil identifikasi dari '
                          'kamera dapat keliru; pastikan jenis tanaman sebelum dikonsumsi.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ActionPanel(plant: plant, scanImage: scanImage, confidence: confidence),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HerbalPlant plant;
  final File? photo;

  const _Header({required this.plant, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            child: PlantThumb(plant: plant, file: photo),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.maybePop(context),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool strong;

  const _Pill({required this.icon, required this.text, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: strong ? AppColors.forest : AppColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15, color: strong ? Colors.white : AppColors.forest),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: strong ? Colors.white : AppColors.forest,
            ),
          ),
        ],
      ),
    );
  }
}

class _CautionBox extends StatelessWidget {
  final List<String> items;

  const _CautionBox({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFF9A6B10), size: 22),
              SizedBox(width: 8),
              Text(
                'Perhatian',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF6E4B0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final c in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                c,
                style: const TextStyle(
                  color: Color(0xFF5C4210),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Panel hijau di bawah: ringkasan cepat + tombol simpan ke koleksi.
class _ActionPanel extends StatelessWidget {
  final HerbalPlant plant;
  final File? scanImage;
  final double? confidence;

  const _ActionPanel({
    required this.plant,
    required this.scanImage,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final col = context.watch<CollectionController>();
    final saved = col.contains(plant.key);
    final hasPhoto = scanImage != null;

    final String label;
    final IconData icon;
    if (saved && !hasPhoto) {
      label = 'Hapus dari koleksi';
      icon = Icons.bookmark_remove_rounded;
    } else if (saved) {
      label = 'Perbarui foto koleksi';
      icon = Icons.bookmark_added_rounded;
    } else {
      label = 'Simpan ke koleksi';
      icon = Icons.bookmark_add_rounded;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.moss,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stat(icon: Icons.spa_rounded, label: 'Bagian dipakai', value: plant.parts),
                  _Stat(icon: Icons.landscape_rounded, label: 'Habitat', value: plant.habitat),
                  _Stat(icon: Icons.local_drink_rounded, label: 'Olahan', value: plant.preparation),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (saved && !hasPhoto) {
                      await col.remove(plant.key);
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                            content: Text('Dihapus dari koleksi')));
                    } else {
                      await col.save(
                        plant.key,
                        image: scanImage,
                        confidence: confidence ?? 0,
                      );
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                            content: Text('Tersimpan di Koleksi Herbal Saya')));
                    }
                  },
                  icon: Icon(icon),
                  label: Text(label),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.forest,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xEBFFFFFF), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
