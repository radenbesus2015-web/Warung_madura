// =======================================================
// ATURAN USAHA YANG WAJIB DIWUJUDKAN

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

/// 2. Aturan Usaha 2: Validasi apakah menu bisa dipesan
bool cekKetersediaanMenu({required bool tersedia, required int porsiTersisa}) {
  return tersedia && porsiTersisa > 0;
}

/// 3. Aturan Usaha 3: Validasi jumlah pesanan tidak boleh melebihi porsi yang tersisa
bool validasiBatasPorsi({required int jumlahPorsi, required int porsiTersisa}) {
  return jumlahPorsi <= porsiTersisa;
}

/// Fungsi Pendukung: Format Rupiah rapi
String formatRupiah(num nominal) {
  // Format manual tanpa dependensi eksternal intl agar langsung kompatibel
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
