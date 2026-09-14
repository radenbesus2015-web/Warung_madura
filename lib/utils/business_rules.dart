// =======================================================
// ATURAN USAHA YANG WAJIB DIWUJUDKAN (PIRING PENUH)
// Ditulis sebagai FUNGSI TERSENDIRI yang mengembalikan nilai
// (Bukan menumpuk di dalam build).
// =======================================================

/// 1. Aturan Usaha 1: Pesanan 5 porsi ke atas untuk satu menu yang sama mendapat potongan 10%
double hitungSubtotalMenu({required int harga, required int jumlahPorsi}) {
  if (jumlahPorsi <= 0) return 0.0;
  double subtotal = (harga * jumlahPorsi).toDouble();
  if (jumlahPorsi >= 5) {
    subtotal = subtotal * 0.90; // Diskon 10%
  }
  return subtotal;
}

/// Menghitung besaran diskon rupiah per item jika pesanan >= 5 porsi
double hitungDiskonItem({required int harga, required int jumlahPorsi}) {
  if (jumlahPorsi < 5) return 0.0;
  return (harga * jumlahPorsi) * 0.10;
}

/// 2. Aturan Usaha 2: Validasi apakah menu bisa dipesan
bool cekKetersediaanMenu({required bool tersedia, required int porsiTersisa}) {
  return tersedia && porsiTersisa > 0;
}

/// 3. Aturan Usaha 3: Validasi jumlah pesanan tidak boleh melebihi porsi yang tersisa
bool validasiBatasPorsi({required int jumlahPorsi, required int porsiTersisa}) {
  return jumlahPorsi <= porsiTersisa;
}

/// 4. Pembulatan pembayaran ke pecahan Rp500 terdekat
int bulatkanKePecahan500(num total) {
  if (total <= 0) return 0;
  return ((total / 500).round()) * 500;
}

/// Fungsi Pendukung: Format Rupiah rapi tanpa library eksternal
String formatRupiah(num nominal) {
  String raw = nominal.toInt().toString();
  String hasil = '';
  int counter = 0;
  for (int i = raw.length - 1; i >= 0; i--) {
    hasil = raw[i] + hasil;
    counter++;
    if (counter % 3 == 0 && i != 0) {
      hasil = '.$hasil';
    }
  }
  return 'Rp $hasil';
}
