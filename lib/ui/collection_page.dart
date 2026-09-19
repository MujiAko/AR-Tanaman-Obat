import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/collection_controller.dart';
import '../data/herbal_data.dart';
import '../model/saved_scan.dart';
import '../theme/app_theme.dart';
import '../widget/plant_card.dart';
import 'plant_detail_page.dart';

/// Page 4 — Koleksi Herbal Saya (Personal Journal & Saved Scans)
class CollectionPage extends StatefulWidget {
  final VoidCallback onScan;

  const CollectionPage({super.key, required this.onScan});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  String _query = '';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  void _open(SavedScan s, HerbalPlant plant) {
    final path = s.imagePath;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantDetailPage(
          plant: plant,
          scanImage: path == null ? null : File(path),
          confidence: s.confidence,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SavedScan s, HerbalPlant plant) async {
    final col = context.read<CollectionController>();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hapus ${plant.name} dari koleksi?',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Foto pindaian yang tersimpan juga akan dihapus dari perangkat.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) await col.remove(s.plantKey);
  }

  @override
  Widget build(BuildContext context) {
    final col = context.watch<CollectionController>();
    final theme = Theme.of(context);

    // Pasangkan entri dengan data tanaman; abaikan yang kuncinya sudah tidak ada.
    final entries = <(SavedScan, HerbalPlant)>[];
    for (final s in col.items) {
      final p = HerbalData.byLabel(s.plantKey);
      if (p == null) continue;
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.latin.toLowerCase().contains(q)) {
        continue;
      }
      entries.add((s, p));
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Koleksi Herbal Saya',
                style: theme.textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              col.items.isEmpty
                  ? 'Jurnal pindaian pribadimu'
                  : '${col.items.length} tanaman tersimpan · tekan lama untuk menghapus',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (col.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari di koleksi',
                  hintStyle: const TextStyle(color: Color(0xFF9AA59E)),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          Expanded(
            child: !col.isLoaded
                ? const Center(child: CircularProgressIndicator())
                : col.items.isEmpty
                    ? _EmptyState(onScan: widget.onScan)
                    : entries.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Tidak ada koleksi yang cocok.',
                                style: theme.textTheme.bodyMedium),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: entries.length,
                            itemBuilder: (_, i) {
                              final (s, p) = entries[i];
                              return PlantCard(
                                plant: p,
                                photo: s.imagePath == null
                                    ? null
                                    : File(s.imagePath!),
                                footnote: _date(s.savedAt),
                                onTap: () => _open(s, p),
                                onLongPress: () => _confirmDelete(s, p),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 40, color: AppColors.forest),
            ),
            const SizedBox(height: 18),
            Text('Koleksimu masih kosong',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Pindai tanaman lalu tekan "Simpan ke koleksi" agar tersimpan di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Pindai tanaman'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
            ),
          ],
        ),
      ),
    );
  }
}
