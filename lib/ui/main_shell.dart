import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widget/herba_nav_bar.dart';
import 'collection_page.dart';
import 'home_page.dart';
import 'scan_page.dart';

/// Kerangka utama: 0 = Beranda, 1 = Kamera Pindai AR, 2 = Koleksi.
/// Halaman kamera hanya dibangun saat tab-nya aktif, sehingga kamera
/// otomatis dinyalakan dan dimatikan mengikuti tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) {
    if (i != _index) setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final Widget page;
    switch (_index) {
      case 1:
        page = ScanPage(key: const ValueKey('scan'), onClose: () => _go(0));
        break;
      case 2:
        page = CollectionPage(key: const ValueKey('collection'), onScan: () => _go(1));
        break;
      default:
        page = HomePage(key: const ValueKey('home'), onScan: () => _go(1));
    }

    return Scaffold(
      backgroundColor: _index == 1 ? Colors.black : AppColors.cream,
      body: page,
      bottomNavigationBar: HerbaNavBar(index: _index, onTap: _go),
    );
  }
}
