import 'dart:io';

import 'package:flutter/foundation.dart';

import '../service/plant_classifier_service.dart';

/// Memuat model TFLite sekali dan menyediakan fungsi klasifikasi untuk layar mana pun.
class ScanController extends ChangeNotifier {
  final PlantClassifierService _service = PlantClassifierService();

  Future<void>? _loading;
  bool _ready = false;
  String? _error;

  bool get isReady => _ready;
  String? get error => _error;

  Future<void> init() {
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      await _service.load();
      _ready = true;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat model: $e';
      _loading = null; // izinkan coba lagi
    }
    notifyListeners();
  }

  Future<ClassificationResult> classify(File image) async {
    await init();
    if (!_ready) throw StateError(_error ?? 'Model belum siap.');
    return _service.classify(image);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
