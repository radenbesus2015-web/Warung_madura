// ==========================================
// MODEL: MenuModel
// Sesuai Spesifikasi:
// - Class buatan sendiri (bukan Map)
// - Konstruktor lengkap
// - Atribut: namaMenu (String), kategori (String), harga (int), tersedia (bool), porsiTersisa (int)
// - Minimal satu method (hitungTotalHargaMenu)
// ==========================================

class MenuItem {
  final String namaMenu;
  final String kategori;
  final int harga;
  final bool tersedia;
  final int porsiTersisa;

  const MenuItem({
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.tersedia,
    required this.porsiTersisa,
  });

  // Aturan Usaha 1: Pesanan 5 porsi ke atas untuk satu menu yang sama mendapat potongan 10%
  // Method pada class MenuItem untuk menghitung harga setelah diskon per porsi pesanan
  double hitungSubtotal(int jumlahPorsi) {
    if (jumlahPorsi <= 0) return 0.0;
    double total = (harga * jumlahPorsi).toDouble();
    if (jumlahPorsi >= 5) {
      total = total * 0.90; // Diskon 10%
    }
    return total;
  }

  // Helper method untuk format keterangan diskon
  String getInfoDiskon(int jumlahPorsi) {
    if (jumlahPorsi >= 5) {
      return 'Diskon 10% aktif!';
    }
    return '';
  }
}
