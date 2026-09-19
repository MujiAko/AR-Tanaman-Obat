import 'dart:io';
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

  Future<ClassificationResult> classify(File imageFile) async {
    final interpreter = _interpreter;
    if (!_isReady || interpreter == null) {
      throw StateError('PlantClassifierService.load() harus dipanggil dulu');
    }

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final height = inputTensor.shape[1];
    final width = inputTensor.shape[2];

    // Decode + resize gambar resolusi penuh di isolate terpisah agar UI tidak macet.
    final rgb = await compute(
      _prepareRgb,
      _PrepArgs(imageFile.path, width, height),
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
  const _PrepArgs(this.path, this.width, this.height);
}

/// Berjalan di isolate: baca berkas, luruskan orientasi EXIF, resize, lalu ratakan ke RGB.
Uint8List _prepareRgb(_PrepArgs a) {
  final bytes = File(a.path).readAsBytesSync();
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) throw Exception('Gagal membaca gambar tanaman.');
  final oriented = image_lib.bakeOrientation(decoded);
  final resized =
      image_lib.copyResize(oriented, width: a.width, height: a.height);

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
