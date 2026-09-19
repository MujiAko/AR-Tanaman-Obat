import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/ui/result_page.dart';
import 'package:submission/service/plant_classifier_service.dart';

class HomeController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final PlantClassifierService _service = PlantClassifierService();

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ClassificationResult? _lastResult;
  ClassificationResult? get lastResult => _lastResult;

  Future<void> init() async {
    await _service.load();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source, maxWidth: 1024, imageQuality: 90);
      if (picked != null) {
        _selectedImage = File(picked.path);
        notifyListeners();
      }
    } catch (e) { debugPrint('Gagal mengambil gambar: $e'); }
  }

  Future<void> classifyAndNavigate(BuildContext context) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil atau pilih foto tanaman terlebih dahulu')));
      return;
    }
    _isLoading = true; notifyListeners();
    try {
      _lastResult = await _service.classify(_selectedImage!);
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResultPage(imageFile: _selectedImage!, result: _lastResult!)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengidentifikasi: $e')));
    } finally { _isLoading = false; notifyListeners(); }
  }

  void clearSelection() { _selectedImage = null; _lastResult = null; notifyListeners(); }
}
