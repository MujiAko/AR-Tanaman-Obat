/// Data monograf tanaman obat untuk 10 kelas pada `labels.csv`.
///
/// Dibuat otomatis dari `tools/plants_kb.py` (satu sumber yang sama dengan
/// dataset VQA). Ubah data di sana lalu jalankan ulang `tools/gen_app.py`.
///
/// Catatan: seluruh informasi bersifat edukatif dan berasal dari penggunaan
/// tradisional. Bukan pengganti diagnosis atau saran tenaga kesehatan.
class HerbalPlant {
  /// Harus sama persis dengan nama kelas di labels.csv
  /// (= nama folder di dataset "Medicinal Plants").
  final String key;
  final String name; // nama tampilan
  final String latin;
  final String category; // 'Daun' | 'Gel'
  final List<String> localNames;
  final String description;
  final List<String> benefits;
  final List<String> compounds; // kandungan aktif utama
  final String parts; // bagian yang dimanfaatkan
  final String habitat;
  final String preparation; // ringkas, untuk panel hijau
  final String howTo; // cara olah tradisional, untuk bagian isi
  final List<String> cautions;

  const HerbalPlant({
    required this.key,
    required this.name,
    required this.latin,
    required this.category,
    required this.localNames,
    required this.description,
    required this.benefits,
    required this.compounds,
    required this.parts,
    required this.habitat,
    required this.preparation,
    required this.howTo,
    required this.cautions,
  });

  /// Nama berkas foto opsional: `assets/plants/slug.jpg`
  String get slug => key.toLowerCase().replaceAll(' ', '_');
  String get assetPath => 'assets/plants/$slug.jpg';
}

class HerbalData {
  HerbalData._();

  static const categories = ['Semua', 'Daun', 'Gel'];

  static HerbalPlant? byLabel(String label) {
    for (final p in plants) {
      if (p.key.toLowerCase() == label.trim().toLowerCase()) return p;
    }
    return null;
  }

  static const plants = <HerbalPlant>[
    HerbalPlant(
      key: 'Daun Jambu Biji',
      name: 'Jambu Biji',
      latin: 'Psidium guajava',
      category: 'Daun',
      localNames: [
        'Jambu klutuk (Jawa)',
        'Jambu batu (Sunda, Melayu)',
        'Jambu siki (Sunda)',
      ],
      description:
          'Daun dari pohon perdu jambu biji, berbentuk lonjong dengan urat daun yang tegas dan '
          'menonjol di bagian bawah. Daun mudanya sudah lama dipakai dalam jamu, sementara '
          'buahnya kaya vitamin C dan serat.',
      benefits: [
        'Rebusan daun secara tradisional dipakai untuk membantu meredakan diare ringan',
        'Rebusan daun dipakai tradisional untuk berkumur saat sariawan',
        'Dipercaya membantu menaikkan trombosit saat demam berdarah, tetapi bukti klinisnya masih terbatas',
      ],
      compounds: [
        'Kuersetin',
        'Flavonoid',
        'Tanin',
      ],
      parts: 'Daun, buah',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Rebusan daun',
      howTo:
          'Cuci 5–7 lembar daun muda, rebus dengan dua gelas air selama 10–15 menit hingga '
          'tersisa kira-kira satu gelas. Saring dan minum selagi hangat.',
      cautions: [
        'Diare yang berlangsung lebih dari dua hari, disertai darah, atau membuat lemas perlu diperiksakan ke tenaga kesehatan.',
        'Demam berdarah adalah kondisi yang perlu penanganan medis; rebusan daun bukan pengganti perawatan.',
        'Konsumsi berlebihan dapat memicu sembelit karena kandungan taninnya.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Kari',
      name: 'Daun Kari',
      latin: 'Murraya koenigii',
      category: 'Daun',
      localNames: [
        'Salam koja (Indonesia)',
        'Temurui (Aceh)',
        'Daun kari (umum)',
      ],
      description:
          'Daun majemuk dari pohon kecil kerabat jeruk, tersusun dari banyak anak daun kecil '
          'yang berjajar di satu tangkai. Aromanya harum tajam saat diremas dan menjadi bumbu '
          'khas masakan Aceh dan Melayu.',
      benefits: [
        'Daun segar dipakai sebagai bumbu aromatik pada gulai dan kari',
        'Secara tradisional dipakai untuk membantu pencernaan dan meredakan mual',
        'Penelitian awal, sebagian besar pada hewan, menunjukkan potensi membantu mengontrol gula darah dan kolesterol',
      ],
      compounds: [
        'Alkaloid karbazol (mahanimbin)',
        'Linalool',
        'Alfa-terpinena',
      ],
      parts: 'Daun',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Bumbu, seduhan',
      howTo:
          'Tumis atau masukkan 1–2 tangkai daun segar ke masakan berkuah sebagai pewangi. Untuk '
          'seduhan, rebus segenggam daun dengan dua gelas air selama 10 menit lalu saring.',
      cautions: [
        'Bukan pengganti obat diabetes; bila sedang memakai obat gula darah, konsultasikan dulu agar gula darah tidak turun terlalu rendah.',
        'Ibu hamil sebaiknya memakai sebatas bumbu masakan.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Kemangi',
      name: 'Kemangi',
      latin: 'Ocimum × africanum',
      category: 'Daun',
      localNames: [
        'Surawung (Sunda)',
        'Lampes (Jawa)',
        'Balakama (Manado, Ternate)',
      ],
      description:
          'Herba kecil berdaun hijau muda dengan aroma segar seperti lemon. Lazim dimakan '
          'mentah sebagai lalapan dan dipakai dalam pepes. Daunnya mengandung minyak atsiri '
          'yang memberi aroma khas.',
      benefits: [
        'Dipercaya membantu mengurangi bau badan dan menyegarkan napas bila rutin dimakan sebagai lalapan',
        'Secara tradisional dipakai untuk membantu meredakan perut kembung',
        'Aromanya dipakai tradisional untuk memberi rasa rileks',
      ],
      compounds: [
        'Sitral',
        'Linalool',
        'Eugenol',
      ],
      parts: 'Daun, bunga, biji',
      habitat: 'Kebun, tepi ladang',
      preparation: 'Lalapan, seduhan',
      howTo:
          'Makan daun segar langsung sebagai lalapan. Untuk seduhan, tuang air panas ke '
          'segenggam daun, diamkan 5–10 menit, lalu saring.',
      cautions: [
        'Ibu hamil dan menyusui sebaiknya berkonsultasi sebelum memakai dalam jumlah besar.',
        'Hentikan penggunaan bila muncul ruam atau gatal.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Kunyit',
      name: 'Kunyit',
      latin: 'Curcuma longa',
      category: 'Daun',
      localNames: [
        'Kunir (Jawa)',
        'Koneng (Sunda)',
        'Konyet (Madura)',
      ],
      description:
          'Daun lebar memanjang dari tanaman kunyit, dengan tulang daun tengah yang jelas dan '
          'aroma harum. Daunnya terutama dipakai sebagai bumbu, sedangkan khasiat obat kunyit '
          'yang paling dikenal berasal dari rimpangnya.',
      benefits: [
        'Daun dipakai sebagai bumbu aromatik pada rendang, pepes, dan gulai',
        'Rimpangnya diminum sebagai jamu (misalnya kunyit asam) dan secara tradisional dipakai untuk nyeri haid ringan serta nyeri sendi',
        'Kurkumin dari rimpang menunjukkan sifat anti-inflamasi dan antioksidan dalam berbagai penelitian',
      ],
      compounds: [
        'Kurkuminoid (terutama di rimpang)',
        'Minyak atsiri',
      ],
      parts: 'Daun, rimpang',
      habitat: 'Kebun, tanah gembur',
      preparation: 'Bumbu, jamu rimpang',
      howTo:
          'Daun: masukkan 1–2 lembar utuh ke masakan berkuah sebagai pewangi. Untuk jamu, parut '
          'satu ruas jari rimpang kunyit, rebus dengan dua gelas air selama 10 menit, saring, '
          'lalu minum hangat. Bisa ditambah asam jawa dan gula aren.',
      cautions: [
        'Penderita batu empedu atau gangguan saluran empedu sebaiknya menghindari kunyit dosis tinggi.',
        'Dapat berinteraksi dengan obat pengencer darah; konsultasikan dulu bila sedang memakainya.',
        'Suplemen kurkumin dosis tinggi pernah dikaitkan dengan gangguan hati; takaran bumbu dan jamu biasa umumnya aman.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Mint',
      name: 'Mint',
      latin: 'Mentha × piperita',
      category: 'Daun',
      localNames: [
        'Daun mint (umum)',
        'Pepermin (umum)',
        'Bijanggut (Sunda)',
      ],
      description:
          'Herba merambat berdaun hijau dengan tepi bergerigi dan aroma mentol yang dingin. '
          'Populer sebagai campuran minuman dan teh herbal.',
      benefits: [
        'Seduhan daun secara tradisional dipakai untuk meredakan perut kembung dan begah',
        'Aroma mentol memberi sensasi lega saat hidung tersumbat',
        'Minyak pepermin yang dioleskan di pelipis dipakai untuk meredakan sakit kepala tegang',
      ],
      compounds: [
        'Mentol',
        'Menton',
        'Limonena',
      ],
      parts: 'Daun',
      habitat: 'Dataran tinggi, tanah lembap',
      preparation: 'Seduhan, uap',
      howTo:
          'Seduh 5–10 lembar daun segar dengan segelas air panas, diamkan 5 menit, lalu minum. '
          'Untuk hidung tersumbat, hirup uap dari seduhan hangat dengan hati-hati.',
      cautions: [
        'Dapat memperburuk keluhan asam lambung naik (GERD).',
        'Jangan oleskan minyak mint atau mentol di wajah atau dekat hidung bayi dan anak kecil karena dapat mengganggu pernapasan.',
        'Minyak atsiri murni tidak untuk diminum.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Pepaya',
      name: 'Pepaya',
      latin: 'Carica papaya',
      category: 'Daun',
      localNames: [
        'Kates (Jawa)',
        'Gedang (Sunda)',
        'Kalikih (Minang)',
      ],
      description:
          'Daun besar menjari dengan tangkai panjang berongga dari pohon pepaya. Daun mudanya '
          'terkenal pahit dan lazim dimasak sebagai sayur atau dijadikan jamu.',
      benefits: [
        'Secara tradisional dipakai untuk membantu meningkatkan nafsu makan',
        'Ekstrak daun diteliti dapat membantu menaikkan trombosit pada demam berdarah; uji klinis yang ada masih kecil',
        'Dipakai tradisional sebagai ramuan saat demam, termasuk di daerah endemis malaria',
      ],
      compounds: [
        'Papain',
        'Karpain',
        'Flavonoid',
      ],
      parts: 'Daun, buah, getah',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Rebusan, perasan',
      howTo:
          'Tumbuk 1–2 lembar daun muda lalu peras airnya, atau rebus dengan dua gelas air '
          'hingga tersisa satu gelas. Buang air rebusan pertama bila terlalu pahit.',
      cautions: [
        'Demam berdarah dan malaria memerlukan pemeriksaan dan pengobatan medis; ramuan daun bukan pengganti.',
        'Ibu hamil sebaiknya menghindari getah dan ramuan daun pepaya.',
        'Getah dapat mengiritasi kulit dan lambung pada orang tertentu.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Sirih',
      name: 'Sirih',
      latin: 'Piper betle',
      category: 'Daun',
      localNames: [
        'Suruh (Jawa)',
        'Seureuh (Sunda)',
        'Ranub (Aceh)',
      ],
      description:
          'Daun dari tanaman merambat, berbentuk hati dengan permukaan hijau mengilap dan aroma '
          'tajam. Sejak lama menjadi bagian adat dan ramuan tradisional karena sifat '
          'antiseptiknya.',
      benefits: [
        'Air rebusan dipakai tradisional untuk berkumur dan menyegarkan mulut',
        'Air rebusan dipakai luar untuk membersihkan luka kecil yang dangkal',
        'Gulungan daun secara tradisional dipakai untuk membantu menghentikan mimisan ringan',
      ],
      compounds: [
        'Kavikol',
        'Eugenol',
        'Minyak atsiri',
      ],
      parts: 'Daun',
      habitat: 'Merambat, tempat teduh lembap',
      preparation: 'Rebusan, kumur',
      howTo:
          'Rebus 3–5 lembar daun dengan dua gelas air hingga mendidih. Dinginkan, lalu pakai '
          'untuk berkumur atau membasuh bagian luar tubuh; jangan ditelan dalam jumlah besar.',
      cautions: [
        'Jangan dipakai untuk membilas bagian dalam organ kewanitaan karena dapat mengganggu keseimbangan bakteri alami.',
        'Mengunyah sirih bersama pinang dan tembakau berkaitan dengan risiko kanker mulut.',
        'Hentikan penggunaan bila muncul iritasi.',
      ],
    ),
    HerbalPlant(
      key: 'Daun Sirsak',
      name: 'Sirsak',
      latin: 'Annona muricata',
      category: 'Daun',
      localNames: [
        'Nangka belanda (Jawa)',
        'Nangka walanda (Sunda)',
        'Durian belanda (Melayu)',
      ],
      description:
          'Daun lonjong hijau tua mengilap dari pohon sirsak, beraroma khas bila diremas. '
          'Buahnya berduri lunak dan berdaging putih, sedangkan daunnya populer sebagai rebusan '
          'herbal.',
      benefits: [
        'Rebusan daun secara tradisional dipakai untuk membantu meredakan asam urat dan menjaga tekanan darah',
        'Mengandung asetogenin yang diteliti di laboratorium karena sifat antikankernya, tetapi belum ada bukti pada manusia',
        'Buahnya kaya vitamin C dan serat',
      ],
      compounds: [
        'Asetogenin (annonasin)',
        'Alkaloid',
        'Flavonoid',
      ],
      parts: 'Daun, buah',
      habitat: 'Pekarangan, dataran rendah',
      preparation: 'Rebusan daun',
      howTo:
          'Rebus 5–7 lembar daun dengan tiga gelas air hingga tersisa kira-kira satu gelas. '
          'Saring dan minum hangat; tidak dianjurkan diminum terus-menerus dalam jangka '
          'panjang.',
      cautions: [
        'Bukan pengganti pengobatan kanker dari dokter.',
        'Konsumsi jangka panjang dikaitkan dengan gangguan saraf (mirip parkinson) karena senyawa annonasin.',
        'Dapat menurunkan tekanan darah dan gula darah; berhati-hati bila sedang memakai obat untuk keduanya.',
        'Tidak dianjurkan untuk ibu hamil.',
      ],
    ),
    HerbalPlant(
      key: 'Lidah Buaya',
      name: 'Lidah Buaya',
      latin: 'Aloe vera',
      category: 'Gel',
      localNames: [
        'Letah buaya (Sunda)',
        'Ilat baya (Jawa)',
        'Jadam (sebutan untuk getahnya yang dikeringkan)',
      ],
      description:
          'Tanaman sukulen berdaun tebal berdaging dengan duri lunak di tepinya. Daunnya '
          'menyimpan gel bening yang banyak dipakai untuk merawat kulit dan rambut.',
      benefits: [
        'Gel dipakai luar untuk melembapkan dan menenangkan luka bakar ringan atau kulit terbakar matahari',
        'Dipakai tradisional untuk merawat kulit kepala dan rambut',
        'Gel yang sudah dibersihkan dari getah kuning dipakai dalam minuman segar',
      ],
      compounds: [
        'Aloin (barbaloin)',
        'Asemanan (polisakarida)',
        'Bradikininase',
      ],
      parts: 'Gel daun',
      habitat: 'Tanah kering, terik matahari',
      preparation: 'Gel oles, minuman',
      howTo:
          'Potong daun, kupas kulitnya, buang getah kuning di dekat kulit, lalu bilas gelnya '
          'hingga bersih. Oleskan tipis pada kulit; uji dulu di area kecil.',
      cautions: [
        'Getah kuning (aloin) di bawah kulit daun bersifat pencahar kuat; buang sebelum memakai, terutama untuk diminum.',
        'Tidak dianjurkan diminum oleh ibu hamil, ibu menyusui, atau anak kecil.',
        'Jangan dioleskan pada luka dalam atau luka bakar berat.',
      ],
    ),
    HerbalPlant(
      key: 'Teh Hijau',
      name: 'Teh Hijau',
      latin: 'Camellia sinensis',
      category: 'Daun',
      localNames: [
        'Teh (umum)',
        'Enteh (Sunda)',
      ],
      description:
          'Daun dari tanaman teh yang diolah tanpa fermentasi sehingga warnanya tetap hijau. '
          'Tumbuh di perkebunan dataran tinggi dan diseduh sebagai minuman sehari-hari.',
      benefits: [
        'Kaya katekin (EGCG) yang bersifat antioksidan',
        'Konsumsi rutin dalam studi pengamatan dikaitkan dengan risiko penyakit jantung yang lebih rendah',
        'Kafein dan L-theanine membantu menjaga fokus dan kewaspadaan',
      ],
      compounds: [
        'Katekin (EGCG)',
        'Kafein',
        'L-theanine',
      ],
      parts: 'Pucuk dan daun muda',
      habitat: 'Perkebunan dataran tinggi',
      preparation: 'Seduhan',
      howTo:
          'Seduh satu sendok teh daun kering dengan air bersuhu sekitar 80 °C (jangan '
          'mendidih), diamkan 2–3 menit, lalu saring.',
      cautions: [
        'Mengandung kafein; batasi bila sedang hamil, sulit tidur, atau jantung sering berdebar.',
        'Suplemen ekstrak teh hijau dosis tinggi dikaitkan dengan gangguan hati; teh seduhan biasa umumnya aman.',
        'Dapat menghambat penyerapan zat besi; penderita anemia sebaiknya minum di luar jam makan.',
      ],
    ),
  ];
}
