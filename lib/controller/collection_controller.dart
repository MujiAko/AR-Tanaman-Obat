import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/saved_scan.dart';

/// Menyimpan "Koleksi Herbal Saya": satu entri per tanaman, terbaru di atas.
/// Metadata disimpan di SharedPreferences; foto disalin ke folder dokumen aplikasi.
class CollectionController extends ChangeNotifier {
  static const _prefsKey = 'collection_v1';

  final List<SavedScan> _items = [];
  bool _loaded = false;

  List<SavedScan> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;

  SavedScan? find(String plantKey) {
    for (final s in _items) {
      if (s.plantKey == plantKey) return s;
    }
    return null;
  }

  bool contains(String plantKey) => find(plantKey) != null;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => SavedScan.fromJson(e as Map<String, dynamic>))
            .toList();
        _items
          ..clear()
          ..addAll(list);
      }
    } catch (e) {
      debugPrint('Gagal memuat koleksi: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  /// Tambah, atau perbarui bila tanaman yang sama sudah ada.
  Future<void> save(
    String plantKey, {
    File? image,
    double confidence = 0,
  }) async {
    final old = find(plantKey);
    String? storedPath = old?.imagePath;

    if (image != null) {
      final copied = await _copyImage(image, plantKey);
      if (copied != null) {
        if (old?.imagePath != null && old!.imagePath != copied) {
          await _deleteFile(old.imagePath!);
        }
        storedPath = copied;
      }
    }

    final entry = SavedScan(
      id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      plantKey: plantKey,
      imagePath: storedPath,
      confidence: image != null ? confidence : (old?.confidence ?? confidence),
      savedAt: DateTime.now(),
    );

    _items.removeWhere((s) => s.plantKey == plantKey);
    _items.insert(0, entry);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String plantKey) async {
    final old = find(plantKey);
    if (old == null) return;
    _items.removeWhere((s) => s.plantKey == plantKey);
    notifyListeners();
    if (old.imagePath != null) await _deleteFile(old.imagePath!);
    await _persist();
  }

  Future<String?> _copyImage(File source, String plantKey) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/collection');
      if (!await dir.exists()) await dir.create(recursive: true);
      final slug = plantKey.toLowerCase().replaceAll(' ', '_');
      final target =
          '${dir.path}/${slug}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await source.copy(target);
      return target;
    } catch (e) {
      debugPrint('Gagal menyalin foto: $e');
      return null;
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Gagal menyimpan koleksi: $e');
    }
  }
}
