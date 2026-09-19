/// Data monograf tanaman obat untuk 10 kelas pada `labels.csv`.
///
/// Catatan: seluruh informasi bersifat edukatif dan berasal dari penggunaan
/// tradisional. Bukan pengganti diagnosis atau saran tenaga kesehatan.
class HerbalPlant {
  /// Harus sama persis dengan nama kelas di labels.csv.
  final String key;
  final String latin;
  final String category; // 'Daun' | 'Buah' | 'Gel'
  final String description;
  final List<String> benefits;
  final String parts; // bagian yang dimanfaatkan
  final String habitat;
  final String preparation; // ringkas, untuk panel hijau
  final String howTo; // cara olah tradisional, untuk bagian isi
  final List<String> cautions;

  const HerbalPlant({
    required this.key,
    required this.latin,
    required this.category,
    required this.description,
    required this.benefits,
    required this.parts,
    required this.habitat,
    required this.preparation,
    required this.howTo,
    required this.cautions,
  });

  String get name => key;

  /// Nama berkas foto opsional: `assets/plants/slug.jpg`
  String get slug => key.toLowerCase().replaceAll(' ', '_');
  String get assetPath => 'assets/plants/$slug.jpg';
}

class HerbalData {
  HerbalData._();

  static const categories = ['Semua', 'Daun', 'Buah', 'Gel'];

  static HerbalPlant? byLabel(String label) {
    for (final p in plants) {
      if (p.key.toLowerCase() == label.trim().toLowerCase()) return p;
    }
    return null;
  }

  static const plants = <HerbalPlant>[
    HerbalPlant(
      key: 'Belimbing Wuluh',
      latin: 'Averrhoa bilimbi',
      category: 'Buah',
      description:
          'Pohon kecil tropis dengan buah hijau berbentuk lonjong yang sangat asam. '
          'Di dapur Nusantara dipakai sebagai pengasam masakan, dan dalam pengobatan '
          'tradisional buah serta daunnya dimanfaatkan untuk keluhan ringan.',
      benefits: [
        'Secara tradisional dipakai untuk meredakan batuk dan radang tenggorokan',
        'Sumber vitamin C dan senyawa antioksidan',
        'Rebusan daun dipakai tradisional untuk keluhan gatal dan bisul ringan',
      ],
      parts: 'Buah, daun',
      habitat: 'Dataran rendah tropis',
      preparation: 'Rebusan, sirup',
      howTo:
          'Rebus 5–7 buah atau segenggam daun dengan dua gelas air hingga tersisa '
          'separuhnya. Saring, minum selagi hangat, dan tambahkan sedikit madu bila terlalu asam.',
      cautions: [
        'Kandungan oksalat tinggi; hindari konsumsi berlebihan bila punya riwayat batu ginjal.',
        'Orang dengan penyakit lambung sebaiknya berhati-hati karena rasanya sangat asam.',
      ],
    ),
    HerbalPlant(
      key: 'Jambu Biji',
      latin: 'Psidium guajava',
      category: 'Daun',
      description:
          'Pohon perdu dengan daun berurat tegas dan buah berdaging harum. Daun mudanya '
          'sudah lama dipakai dalam jamu, sementara buahnya kaya vitamin C dan serat.',
      benefits: [
        'Daun secara tradisional diseduh untuk membantu meredakan diare ringan',
        'Buah kaya vitamin C, serat, dan antioksidan',
        'Rebusan daun dipakai tradisional untuk berkumur saat sariawan',
      ],
      parts: 'Daun, buah',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Seduhan daun, jus',
      howTo:
          'Cuci 5–7 lembar daun muda, rebus dengan dua gelas air selama 10–15 menit hingga '
          'tersisa satu gelas. Saring dan minum hangat.',
      cautions: [
        'Diare yang berlangsung lebih dari dua hari perlu diperiksakan ke tenaga kesehatan.',
        'Konsumsi daun berlebihan dapat memicu sembelit pada sebagian orang.',
      ],
    ),
    HerbalPlant(
      key: 'Jeruk Nipis',
      latin: 'Citrus aurantiifolia',
      category: 'Buah',
      description:
          'Jeruk kecil berkulit tipis dengan sari sangat asam dan aroma segar. '
          'Populer sebagai bumbu, penyegar, dan campuran ramuan batuk tradisional.',
      benefits: [
        'Sumber vitamin C untuk membantu daya tahan tubuh',
        'Campuran kecap atau madu dipakai tradisional untuk meredakan batuk',
        'Air perasan membantu menyegarkan mulut dan tenggorokan',
      ],
      parts: 'Buah, kulit',
      habitat: 'Kebun, pekarangan tropis',
      preparation: 'Perasan, air hangat',
      howTo:
          'Peras setengah buah ke dalam segelas air hangat, tambahkan madu secukupnya. '
          'Minum pelan-pelan; jangan diminum saat perut kosong bila lambung sensitif.',
      cautions: [
        'Keasaman tinggi dapat memicu nyeri lambung pada penderita maag atau GERD.',
        'Kulit dapat lebih sensitif terhadap sinar matahari setelah terkena sari buahnya.',
      ],
    ),
    HerbalPlant(
      key: 'Kemangi',
      latin: 'Ocimum americanum',
      category: 'Daun',
      description:
          'Herba beraroma tajam yang lazim dimakan mentah sebagai lalapan. '
          'Daunnya mengandung minyak atsiri yang memberi aroma khas dan dimanfaatkan dalam ramuan tradisional.',
      benefits: [
        'Secara tradisional dipakai untuk membantu meredakan perut kembung',
        'Membantu menyegarkan napas bila dikunyah segar',
        'Mengandung antioksidan dan minyak atsiri',
      ],
      parts: 'Daun, bunga, biji',
      habitat: 'Kebun, tepi ladang',
      preparation: 'Lalapan, seduhan',
      howTo:
          'Seduh segenggam daun segar dengan air panas selama 5–10 menit, lalu saring. '
          'Daun segar juga dapat dimakan langsung sebagai lalapan.',
      cautions: [
        'Ibu hamil dan menyusui sebaiknya berkonsultasi sebelum memakai dalam jumlah besar.',
        'Hentikan penggunaan bila muncul ruam atau gatal.',
      ],
    ),
    HerbalPlant(
      key: 'Lidah Buaya',
      latin: 'Aloe vera',
      category: 'Gel',
      description:
          'Tanaman sukulen berdaun tebal berduri lembut yang menyimpan gel bening. '
          'Gelnya banyak dipakai untuk merawat kulit dan menenangkan kulit yang teriritasi.',
      benefits: [
        'Gel dipakai luar untuk melembapkan dan menenangkan kulit terbakar matahari ringan',
        'Membantu menjaga kelembapan kulit dan rambut',
        'Gel murni juga dipakai tradisional dalam minuman segar',
      ],
      parts: 'Gel daun',
      habitat: 'Tanah kering, terik matahari',
      preparation: 'Gel oles, jus',
      howTo:
          'Potong daun, buang kulit dan getah kuning di dekat kulit daun, lalu bilas gelnya '
          'hingga bersih. Oleskan tipis pada kulit; uji dulu pada area kecil.',
      cautions: [
        'Getah kuning (lateks) di bawah kulit daun bersifat pencahar kuat; buang sebelum memakai.',
        'Tidak dianjurkan diminum oleh ibu hamil, menyusui, atau anak kecil tanpa arahan tenaga kesehatan.',
        'Jangan dioleskan pada luka dalam atau luka bakar berat.',
      ],
    ),
    HerbalPlant(
      key: 'Nangka',
      latin: 'Artocarpus heterophyllus',
      category: 'Buah',
      description:
          'Pohon besar dengan buah raksasa berdaging manis beraroma kuat. '
          'Selain dimakan sebagai buah, nangka muda dimasak sebagai sayur dan bijinya diolah menjadi camilan.',
      benefits: [
        'Buah kaya serat, vitamin C, dan kalium',
        'Biji yang dimasak matang sumber karbohidrat dan protein',
        'Daun dipakai tradisional sebagai rebusan penyegar badan',
      ],
      parts: 'Buah, biji, daun',
      habitat: 'Dataran rendah tropis',
      preparation: 'Dimakan, direbus',
      howTo:
          'Konsumsi daging buah matang segar. Biji harus direbus atau dipanggang hingga matang '
          'sebelum dimakan; jangan dimakan mentah.',
      cautions: [
        'Buah manis cukup tinggi gula; penderita diabetes perlu memperhatikan porsi.',
        'Getah nangka dapat memicu alergi kulit pada orang yang sensitif.',
      ],
    ),
    HerbalPlant(
      key: 'Pandan',
      latin: 'Pandanus amaryllifolius',
      category: 'Daun',
      description:
          'Tanaman rumpun berdaun panjang meruncing dengan aroma wangi khas. '
          'Dikenal sebagai pewangi makanan dan minuman, juga dipakai dalam ramuan tradisional.',
      benefits: [
        'Aromanya dipakai tradisional untuk memberi rasa rileks',
        'Rebusan daun dipakai tradisional untuk meredakan pegal',
        'Pewangi alami untuk makanan dan minuman',
      ],
      parts: 'Daun, akar',
      habitat: 'Tepi sungai, tanah lembap',
      preparation: 'Rebusan, pewangi',
      howTo:
          'Cuci 2–3 lembar daun, simpulkan, lalu rebus dengan dua gelas air selama 10 menit. '
          'Minum hangat, dapat ditambah sedikit gula aren.',
      cautions: [
        'Klaim khasiat untuk tekanan darah belum cukup dibuktikan; jangan menggantikan obat dari dokter.',
      ],
    ),
    HerbalPlant(
      key: 'Pepaya',
      latin: 'Carica papaya',
      category: 'Daun',
      description:
          'Pohon berbatang lurus dengan daun menjari besar. Buah, daun, dan getahnya '
          'dimanfaatkan; daun mudanya dikenal pahit dan lazim dijadikan sayur atau jamu.',
      benefits: [
        'Buah kaya serat dan vitamin A serta C untuk membantu pencernaan',
        'Daun dipakai tradisional untuk membantu meningkatkan nafsu makan',
        'Mengandung enzim papain yang membantu memecah protein',
      ],
      parts: 'Buah, daun, getah',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Dimakan, rebusan daun',
      howTo:
          'Rebus 1 lembar daun muda dengan dua gelas air hingga tersisa satu gelas, buang '
          'air rebusan pertama bila terlalu pahit. Buah matang bisa dimakan langsung.',
      cautions: [
        'Ibu hamil sebaiknya menghindari buah mentah dan getahnya.',
        'Getah dapat mengiritasi kulit dan lambung pada orang tertentu.',
      ],
    ),
    HerbalPlant(
      key: 'Seledri',
      latin: 'Apium graveolens',
      category: 'Daun',
      description:
          'Herba bertangkai renyah dengan daun bergerigi beraroma tajam. '
          'Sering dipakai sebagai penyedap sup, dan dalam pengobatan tradisional dikenal untuk menjaga tekanan darah.',
      benefits: [
        'Secara tradisional dipakai untuk membantu menjaga tekanan darah normal',
        'Bersifat diuretik ringan, membantu melancarkan buang air kecil',
        'Mengandung serat, vitamin K, dan antioksidan',
      ],
      parts: 'Batang, daun, biji',
      habitat: 'Dataran tinggi sejuk',
      preparation: 'Jus, rebusan',
      howTo:
          'Rebus 2–3 batang seledri lengkap dengan daunnya dalam dua gelas air selama '
          '10 menit, saring, lalu minum hangat. Bisa juga dijus bersama buah.',
      cautions: [
        'Penderita tekanan darah rendah atau pemakai obat pengencer darah perlu berkonsultasi dulu.',
        'Ibu hamil sebaiknya tidak memakai dalam jumlah besar.',
      ],
    ),
    HerbalPlant(
      key: 'Sirih',
      latin: 'Piper betle',
      category: 'Daun',
      description:
          'Tanaman merambat berdaun hijau mengilap berbentuk hati. Sejak lama menjadi bagian '
          'adat dan ramuan tradisional karena aromanya yang tajam dan sifat antiseptiknya.',
      benefits: [
        'Rebusan daun dipakai tradisional untuk berkumur dan menyegarkan mulut',
        'Air rebusan dipakai luar untuk membersihkan luka kecil yang dangkal',
        'Mengandung senyawa fenol yang bersifat antiseptik',
      ],
      parts: 'Daun',
      habitat: 'Merambat, tempat teduh lembap',
      preparation: 'Rebusan, kumur',
      howTo:
          'Rebus 5–7 lembar daun dengan dua gelas air selama 10–15 menit. Dinginkan, lalu '
          'pakai sebagai obat kumur atau pembersih luka kecil; jangan ditelan dalam jumlah besar.',
      cautions: [
        'Mengunyah sirih bersama pinang dan tembakau berkaitan dengan risiko kanker mulut.',
        'Hentikan penggunaan bila muncul iritasi.',
      ],
    ),
  ];
}
