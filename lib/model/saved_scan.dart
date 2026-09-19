/// Satu entri di "Koleksi Herbal Saya".
class SavedScan {
  final String id;
  final String plantKey;
  final String? imagePath; // salinan foto di penyimpanan aplikasi (opsional)
  final double confidence; // 0.0 - 1.0, 0 bila disimpan manual tanpa pemindaian
  final DateTime savedAt;

  const SavedScan({
    required this.id,
    required this.plantKey,
    required this.savedAt,
    this.imagePath,
    this.confidence = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantKey': plantKey,
        'imagePath': imagePath,
        'confidence': confidence,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedScan.fromJson(Map<String, dynamic> json) => SavedScan(
        id: json['id'] as String,
        plantKey: json['plantKey'] as String,
        imagePath: json['imagePath'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
