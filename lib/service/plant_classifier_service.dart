import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassificationResult {
  final String label;
  final double confidence; // 0.0 - 1.0
  final bool isRecognized;

  const ClassificationResult({
    required this.label,
    required this.confidence,
    this.isRecognized = true,
  });

  const ClassificationResult.unknown()
      : label = 'Tanaman tidak dikenali',
        confidence = 0.0,
        isRecognized = false;

  String get confidencePercentText =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}

class PlantClassifierService {
  static const String _modelPath = 'assets/models/model.tflite';
  static const String _labelsPath = 'assets/models/labels.csv';

  /// Di bawah nilai ini hasil dianggap bukan tanaman obat yang dikenal.
  static const double confidenceThreshold = 0.45;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> load() async {
    if (_isReady) return;
    _interpreter = await Interpreter.fromAsset(_modelPath);
    _labels = await _loadLabels();
    _isReady = true;
  }

  /// labels.csv berformat "0 Belimbing Wuluh" (indeks + spasi + nama).
  /// Parser ini juga menerima "0,Belimbing Wuluh" atau hanya "Belimbing Wuluh".
  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsPath);
    final withIndex = RegExp(r'^\d+\s*[,\s]\s*(.+)$');
    final names = <String>[];
    for (final line in raw.split('\n')) {
      final text = line.replaceAll('\r', '').trim();
      if (text.isEmpty) continue;
      final match = withIndex.firstMatch(text);
      final name = (match != null ? match.group(1)! : text)
          .replaceAll('"', '')
          .trim();
      names.add(name);
    }
    return names;
  }

  /// Klasifikasi gambar dengan opsi crop ke area viewfinder.
  ///
  /// [cropFraction] — fraksi 0.0–1.0 dari lebar/tinggi gambar yang akan
  /// diambil dari tengah. Contoh: 0.6 berarti hanya 60% area tengah gambar
  /// yang dikirim ke model, sehingga background tepi dibuang.
  /// Nilai null atau 1.0 = tanpa crop tambahan (pakai seluruh gambar).
  Future<ClassificationResult> classify(
    File imageFile, {
    double? cropFraction,
  }) async {
    final interpreter = _interpreter;
    if (!_isReady || interpreter == null) {
      throw StateError('PlantClassifierService.load() harus dipanggil dulu');
    }

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final height = inputTensor.shape[1];
    final width = inputTensor.shape[2];

    // Decode + center-crop + resize di isolate terpisah agar UI tidak macet.
    final rgb = await compute(
      _prepareRgb,
      _PrepArgs(imageFile.path, width, height, cropFraction: cropFraction),
    );

    final isInputQuantized = inputTensor.type == TensorType.uint8;
    final Object input = isInputQuantized
        ? _toUint8Input(rgb, width, height)
        : _toFloatInput(rgb, width, height);

    final numClasses = outputTensor.shape[1];
    final isOutputQuantized = outputTensor.type == TensorType.uint8;
    final List<List<Object>> output = isOutputQuantized
        ? [List.filled(numClasses, 0)]
        : [List.filled(numClasses, 0.0)];

    interpreter.run(input, output);

    final rawScores = output[0];
    final List<double> scores;
    if (isOutputQuantized) {
      final scale = outputTensor.params.scale;
      final zeroPoint = outputTensor.params.zeroPoint;
      scores =
          rawScores.map((v) => ((v as int) - zeroPoint) * scale).toList();
    } else {
      scores = rawScores.cast<double>();
    }

    var bestIndex = 0;
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    if (bestScore < confidenceThreshold || bestIndex >= _labels.length) {
      return const ClassificationResult.unknown();
    }
    return ClassificationResult(label: _labels[bestIndex], confidence: bestScore);
  }

  List<List<List<List<double>>>> _toFloatInput(
      Uint8List rgb, int width, int height) {
    return List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final o = (y * width + x) * 3;
          return [rgb[o] / 255.0, rgb[o + 1] / 255.0, rgb[o + 2] / 255.0];
        }),
      ),
    );
  }

  List<List<List<List<int>>>> _toUint8Input(
      Uint8List rgb, int width, int height) {
    return List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final o = (y * width + x) * 3;
          return [rgb[o], rgb[o + 1], rgb[o + 2]];
        }),
      ),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isReady = false;
  }
}

class _PrepArgs {
  final String path;
  final int width;
  final int height;

  /// Fraksi area tengah yang diambil (0.0–1.0). null = tanpa crop tambahan.
  final double? cropFraction;

  const _PrepArgs(this.path, this.width, this.height, {this.cropFraction});
}

/// Berjalan di isolate: baca berkas → EXIF → crop area viewfinder →
/// center-crop ke persegi → normalize brightness → resize → ratakan ke RGB.
Uint8List _prepareRgb(_PrepArgs a) {
  final bytes = File(a.path).readAsBytesSync();
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) throw Exception('Gagal membaca gambar tanaman.');
  var img = image_lib.bakeOrientation(decoded);

  // ── 1. Crop ke area viewfinder (buang tepi yang tidak relevan) ──
  final cf = a.cropFraction;
  if (cf != null && cf > 0.0 && cf < 1.0) {
    final cw = (img.width * cf).round();
    final ch = (img.height * cf).round();
    final cx = (img.width - cw) ~/ 2;
    final cy = (img.height - ch) ~/ 2;
    img = image_lib.copyCrop(img, x: cx, y: cy, width: cw, height: ch);
  }

  // ── 2. Center-crop ke persegi (bukan stretch!) ──
  // Ini memastikan aspect-ratio objek tetap sama seperti foto dataset.
  final side = math.min(img.width, img.height);
  if (img.width != img.height) {
    final sx = (img.width - side) ~/ 2;
    final sy = (img.height - side) ~/ 2;
    img = image_lib.copyCrop(img, x: sx, y: sy, width: side, height: side);
  }

  // ── 3. Normalize brightness/contrast (auto-levels sederhana) ──
  // Cari min dan max luminance, lalu stretch ke rentang 0–255.
  // Ini mengurangi dampak pencahayaan yang bervariasi dari kamera.
  img = _autoNormalize(img);

  // ── 4. Resize ke ukuran input model ──
  final resized = image_lib.copyResize(
    img,
    width: a.width,
    height: a.height,
    interpolation: image_lib.Interpolation.linear,
  );

  // ── 5. Ratakan ke buffer RGB ──
  final out = Uint8List(a.width * a.height * 3);
  var i = 0;
  for (var y = 0; y < a.height; y++) {
    for (var x = 0; x < a.width; x++) {
      final p = resized.getPixel(x, y);
      out[i++] = p.r.toInt();
      out[i++] = p.g.toInt();
      out[i++] = p.b.toInt();
    }
  }
  return out;
}

/// Auto-normalize: stretch histogram channel-wise sehingga rentang warna
/// selalu memanfaatkan 0–255. Efeknya mirip "auto levels" di editor foto.
/// Ini membuat model menerima input yang lebih konsisten meski pencahayaan
/// di kamera jauh berbeda dari foto dataset.
image_lib.Image _autoNormalize(image_lib.Image img) {
  // Sampling cepat: ambil statistik dari setiap piksel.
  int rMin = 255, gMin = 255, bMin = 255;
  int rMax = 0, gMax = 0, bMax = 0;

  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      final p = img.getPixel(x, y);
      final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
      if (r < rMin) rMin = r;
      if (r > rMax) rMax = r;
      if (g < gMin) gMin = g;
      if (g > gMax) gMax = g;
      if (b < bMin) bMin = b;
      if (b > bMax) bMax = b;
    }
  }

  // Kalau kontras sudah cukup lebar (>200 range), skip saja.
  final rangeR = rMax - rMin;
  final rangeG = gMax - gMin;
  final rangeB = bMax - bMin;
  if (rangeR > 200 && rangeG > 200 && rangeB > 200) return img;

  // Hindari division by zero.
  final sR = rangeR > 0 ? 255.0 / rangeR : 1.0;
  final sG = rangeG > 0 ? 255.0 / rangeG : 1.0;
  final sB = rangeB > 0 ? 255.0 / rangeB : 1.0;

  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      final p = img.getPixel(x, y);
      img.setPixelRgba(
        x,
        y,
        ((p.r.toInt() - rMin) * sR).round().clamp(0, 255),
        ((p.g.toInt() - gMin) * sG).round().clamp(0, 255),
        ((p.b.toInt() - bMin) * sB).round().clamp(0, 255),
        p.a.toInt(),
      );
    }
  }
  return img;
}
