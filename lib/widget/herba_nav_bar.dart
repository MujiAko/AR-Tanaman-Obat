import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Navigasi bawah: Beranda · Pindai (tombol tengah) · Koleksi.
class HerbaNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const HerbaNavBar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  selected: index == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(child: Center(child: _ScanButton(
                selected: index == 1,
                onTap: () => onTap(1),
              ))),
              Expanded(
                child: _NavItem(
                  icon: Icons.bookmark_rounded,
                  label: 'Koleksi',
                  selected: index == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : const Color(0xFF9AA59E);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _ScanButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Pindai tanaman',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: selected ? AppColors.leaf : AppColors.forest,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mint, width: 4),
          ),
          child: const Icon(
            Icons.center_focus_strong_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
