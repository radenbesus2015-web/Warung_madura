
class MenuItem {
  final String namaMenu;
  final String kategori;
  final int harga;
  final bool tersedia;
  final int porsiTersisa;
  final String imageUrl;

  const MenuItem({
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.tersedia,
    required this.porsiTersisa,
    this.imageUrl = '',
  });

  // Aturan Usaha 1: Pesanan 5 porsi ke atas untuk satu menu yang sama mendapat potongan 10%
  double hitungSubtotal(int jumlahPorsi) {
    if (jumlahPorsi <= 0) return 0.0;
    double total = (harga * jumlahPorsi).toDouble();
    if (jumlahPorsi >= 5) {
      total = total * 0.90; // Diskon 10%
    }
    return total;
  }

  // Menghitung besaran diskon yang didapat
  double hitungDiskon(int jumlahPorsi) {
    if (jumlahPorsi < 5) return 0.0;
    return (harga * jumlahPorsi) * 0.10;
  }

  // Helper method untuk format keterangan diskon
  String getInfoDiskon(int jumlahPorsi) {
    if (jumlahPorsi >= 5) {
      return 'Diskon 10% aktif!';
    }
    return '';
  }

  MenuItem copyWith({
    String? namaMenu,
    String? kategori,
    int? harga,
    bool? tersedia,
    int? porsiTersisa,
    String? imageUrl,
  }) {
    return MenuItem(
      namaMenu: namaMenu ?? this.namaMenu,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      tersedia: tersedia ?? this.tersedia,
      porsiTersisa: porsiTersisa ?? this.porsiTersisa,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
