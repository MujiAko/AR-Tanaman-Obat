import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/collection_controller.dart';
import '../data/herbal_data.dart';
import '../theme/app_theme.dart';
import '../widget/plant_card.dart';
import 'plant_detail_page.dart';

/// Page 1 — Beranda (Home & Discovery Hub)
class HomePage extends StatefulWidget {
  final VoidCallback onScan;

  const HomePage({super.key, required this.onScan});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  String _category = HerbalData.categories.first;

  List<HerbalPlant> get _filtered {
    final q = _query.trim().toLowerCase();
    return HerbalData.plants.where((p) {
      final inCategory = _category == 'Semua' || p.category == _category;
      final matches = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.latin.toLowerCase().contains(q) ||
          p.benefits.any((b) => b.toLowerCase().contains(q));
      return inCategory && matches;
    }).toList();
  }

  void _open(HerbalPlant plant) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlantDetailPage(plant: plant)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<CollectionController>();
    final plants = _filtered;
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HerbaScan', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          'Kenali tanaman obat\ndi sekitarmu',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: AppColors.forest),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(child: _SearchField(onChanged: (v) {
              setState(() => _query = v);
            })),
          ),
          if (_query.trim().isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _ScanBanner(onScan: widget.onScan),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 62,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                scrollDirection: Axis.horizontal,
                itemCount: HerbalData.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = HerbalData.categories[i];
                  final selected = c == _category;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: AppColors.forest,
                    backgroundColor: AppColors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                plants.isEmpty
                    ? 'Tidak ada hasil'
                    : 'Ditemukan ${plants.length} tanaman',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          if (plants.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Text(
                  'Coba kata kunci lain, misalnya nama tanaman atau keluhan seperti "batuk".',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = plants[i];
                    return PlantCard(
                      plant: p,
                      saved: saved.contains(p.key),
                      onTap: () => _open(p),
                    );
                  },
                  childCount: plants.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari tanaman atau khasiat',
        hintStyle: const TextStyle(color: Color(0xFF9AA59E)),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget {
  final VoidCallback onScan;

  const _ScanBanner({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.moss,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temukan nama dan khasiatnya lewat kamera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dekatkan kamera ke daun atau buah pada cahaya yang cukup.',
                  style: TextStyle(color: Color(0xEBFFFFFF), fontSize: 13),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
                  label: const Text('Mulai pindai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.forest,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}
