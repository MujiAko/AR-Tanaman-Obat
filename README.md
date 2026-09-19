# HerbaScan: AR Tanaman Obat Identifier

Aplikasi Flutter untuk mengidentifikasi jenis tanaman obat dari sebuah foto menggunakan model *machine learning* berbasis *on-device inference* (TensorFlow Lite / LiteRT).

## Fitur Utama

### 1. Pengambilan Gambar
- Pengguna dapat mengambil foto tanaman langsung dari kamera atau memilih dari galeri.
- Gambar yang dipilih ditampilkan sebagai preview di halaman utama sebelum dianalisis.

### 2. Identifikasi Tanaman dengan Machine Learning
- Menggunakan model custom **Plant Classifier** yang terlatih untuk mengenali 10 jenis tanaman obat.
- Inferensi dijalankan secara *on-device* menggunakan **LiteRT (TensorFlow Lite)** melalui package `tflite_flutter`, tanpa memerlukan koneksi internet saat proses klasifikasi.

### 3. Halaman Hasil Prediksi
- Menampilkan foto tanaman yang dianalisis.
- Menampilkan nama tanaman herbal hasil identifikasi model.
- Menampilkan *confidence score* (tingkat keyakinan model) dalam bentuk persentase.

## Teknologi yang Digunakan

| Komponen | Package/Teknologi |
|----------------------|----------------------------|
| Framework | Flutter |
| Pengambilan gambar | `image_picker` |
| Inferensi ML | `tflite_flutter` (LiteRT) |
| Pemrosesan gambar | `image` |
| Parsing label tanaman | `csv` |
| State management | `provider` |

## Struktur Proyek

```
lib/
├── controller/
│   └── home_controller.dart      # Mengelola state gambar yang dipilih & navigasi
├── service/
│   └── plant_classifier_service.dart  # Memuat model TFLite & menjalankan inferensi
├── ui/
│   ├── home_page.dart             # Halaman utama: ambil/pilih gambar tanaman
│   └── result_page.dart           # Halaman hasil: foto + nama tanaman + confidence
└── widget/
    └── classification_item.dart   # Widget tampilan hasil klasifikasi

assets/
└── models/
    ├── model.tflite               # Model machine learning tanaman obat
    └── labels.csv                 # Daftar nama tanaman obat (10 kelas)
```

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK sudah terpasang (`flutter doctor` untuk memastikan environment siap).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Hubungkan perangkat Android (fisik atau emulator).
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Cara Menggunakan Aplikasi

1. Buka aplikasi, akan tampil halaman utama HerbaScan.
2. Ketuk ikon kamera atau galeri untuk mengambil/memilih foto daun/tanaman obat.
3. Setelah gambar terpilih, preview-nya akan tampil di layar.
4. Ketuk tombol **"Identifikasi"** untuk memulai proses analisis.
5. Aplikasi akan menampilkan halaman hasil berisi foto, nama tanaman obat, dan *confidence score*.

## Catatan Model

Model yang digunakan dirancang khusus untuk klasifikasi 10 jenis tanaman obat:
- Input berupa gambar terproses ke ukuran tensor (RGB).
- Dilengkapi dengan *Confidence Threshold* (0.45) untuk menyaring objek di luar kategori tanaman obat.
