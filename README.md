# Food Recognizer App

Aplikasi Flutter yang dapat mengidentifikasi jenis makanan dari sebuah foto menggunakan model *machine learning* yang berjalan langsung di perangkat (on-device inference).

## Fitur Utama

### 1. Pengambilan Gambar
- Pengguna dapat mengambil foto makanan langsung dari kamera atau memilih dari galeri.
- Gambar yang dipilih langsung ditampilkan sebagai preview di halaman utama sebelum dianalisis.

### 2. Identifikasi Makanan dengan Machine Learning
- Menggunakan model **Food Classifier V1** dari Google (AIY), yang mampu mengenali sekitar 2023 jenis makanan.
- Inferensi dijalankan secara on-device menggunakan **LiteRT (TensorFlow Lite)** melalui package `tflite_flutter`, sehingga tidak memerlukan koneksi internet saat proses klasifikasi.

### 3. Halaman Hasil Prediksi
- Menampilkan foto makanan yang dianalisis.
- Menampilkan nama makanan hasil identifikasi model.
- Menampilkan confidence score (tingkat keyakinan model) dalam bentuk persentase.

## Teknologi yang Digunakan

| Komponen             | Package/Teknologi         |
|----------------------|----------------------------|
| Framework             | Flutter                   |
| Pengambilan gambar    | `image_picker`             |
| Inferensi ML          | `tflite_flutter` (LiteRT)  |
| Pemrosesan gambar     | `image`                    |
| Parsing label makanan | `csv`                      |
| State management      | `provider`                 |

## Struktur Proyek

```
lib/
├── controller/
│   └── home_controller.dart      # Mengelola state gambar yang dipilih & navigasi
├── service/
│   └── food_classifier_service.dart  # Memuat model TFLite & menjalankan inferensi
├── ui/
│   ├── home_page.dart             # Halaman utama: ambil/pilih gambar
│   └── result_page.dart           # Halaman hasil: foto + nama makanan + confidence
└── widget/
    └── classification_item.dart   # Widget tampilan hasil klasifikasi

assets/
└── models/
    ├── food_classifier.tflite     # Model machine learning
    └── labels.csv                 # Daftar nama makanan (label)
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

1. Buka aplikasi, akan tampil Home Page dengan ikon gambar di tengah layar.
2. Ketuk ikon tersebut, lalu pilih ** "Ambil dari Kamera" ** atau ** "Pilih dari Galeri" **.
3. Setelah gambar terpilih, preview-nya akan tampil di Home Page.
4. Ketuk tombol ** "Analyze" ** untuk memulai proses identifikasi.
5. Aplikasi akan menampilkan halaman hasil berisi foto, nama makanan, dan confidence score.

## Catatan Model

Model yang digunakan memiliki beberapa keterbatasan sesuai dokumentasi resminya:
- Input berupa gambar 224x224 piksel (RGB).
- Output berupa probabilitas dari sekitar 2023 kategori makanan.
- Model tidak dirancang untuk menentukan apakah suatu makanan aman dikonsumsi, memperkirakan bahan-bahan, menghitung nutrisi, atau mengidentifikasi objek non-makanan.