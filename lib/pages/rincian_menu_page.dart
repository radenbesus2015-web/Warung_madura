import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';
import '../widgets/jumlah_porsi_counter.dart';

// =======================================================
// FITUR PILIHAN (F5): HALAMAN RINCIAN MENU
// Menekan kartu menu akan membuka halaman ini untuk menampilkan
// seluruh data menu secara lengkap (foto, kategori, harga, stok,
// status ketersediaan, deskripsi, dan pengatur porsi).
// =======================================================

class RincianMenuPage extends StatefulWidget {
  final MenuItem item;
  final int initialPorsi;
  final ValueChanged<int> onPorsiChanged;

  const RincianMenuPage({
    super.key,
    required this.item,
    required this.initialPorsi,
    required this.onPorsiChanged,
  });

  @override
  State<RincianMenuPage> createState() => _RincianMenuPageState();
}

class _RincianMenuPageState extends State<RincianMenuPage> {
  late int _jumlahPorsi;

  @override
  void initState() {
    super.initState();
    _jumlahPorsi = widget.initialPorsi;
  }

  void _handlePorsiChanged(int newVal) {
    setState(() {
      _jumlahPorsi = newVal;
    });
    widget.onPorsiChanged(newVal);
  }

  String _getDeskripsiMenu(String nama) {
    switch (nama.toLowerCase()) {
      case 'rawon':
        return 'Sup daging sapi berkuah hitam pekat khas Jawa Timur dengan aroma kluwek yang khas dan gurih. Disajikan dengan tauge pendek, telur asin, dan sambal terasi yang menggugah selera.';
      case 'soto':
        return 'Soto ayam tradisional dengan kuah kuning aromatik yang hangat dan kaya rempah. Dilengkapi suwiran ayam gurih, soun lembut, taburan koya, dan perasan jeruk nipis segar.';
      case 'ayam bakar':
        return 'Ayam pilihan yang diungkep dengan bumbu rempah manis gurih khas nusantara, lalu dipanggang hingga harum karamel. Dihidangkan dengan sambal bajak dan lalapan segar.';
      case 'ayam goreng':
        return 'Ayam goreng renyah di luar dan juicy di dalam dengan bumbu rempah meresap sempurna hingga ke serat daging. Sangat nikmat dinikmati selagi hangat.';
      case 'ayam geprek':
        return 'Ayam goreng krispi renyah yang digeprek bersama cabai rawit pedas mantap. Menghadirkan perpaduan rasa gurih dan pedas nendang favorit semua kalangan.';
      case 'bebek bakar':
        return 'Daging bebek empuk tanpa aroma amis yang dibakar perlahan dengan olesan bumbu kecap manis pedas. Memberikan sensasi rasa gurih pekat yang memanjakan lidah.';
      case 'es teh':
        return 'Teh melati pilihan yang diseduh pekat dan disajikan dingin dengan es batu segar. Melegakan dahaga dan cocok sebagai teman makan menu apa saja.';
      case 'es jeruk':
        return 'Perasan jeruk peras asli dengan rasa manis asam alami yang menyegarkan tubuh seketika. Mengandung vitamin C alami tanpa pemanis buatan berlebih.';
      case 'kopi hitam':
        return 'Kopi tubruk murni dari biji kopi Nusantara pilihan dengan cita rasa mantap, aroma wangi yang pekat, dan aftertaste yang bersih.';
      case 'jus alpukat':
        return 'Jus buah alpukat mentega kental asli yang lembut dan creamy, dipadukan dengan kucuran susu kental manis cokelat premium.';
      case 'wedang jahe':
        return 'Minuman herbal jahe hangat tradisional yang diseduh dengan gula merah dan rempah pilihan. Sangat berkhasiat menghangatkan badan dan menjaga stamina.';
      case 'air mineral':
        return 'Air mineral higienis dan bersih dalam kemasan dingin menyegarkan, menjaga hidrasi tubuh sepanjang hari.';
      case 'tempe mendoan':
        return 'Tempe kedelai berbalut adonan tepung daun bawang gurih yang digoreng setengah matang (mendo). Disajikan hangat bersama sambal kecap cabai rawit.';
      case 'tahu goreng':
        return 'Tahu putih segar goreng berkulit renyah dengan bagian dalam yang lembut dan gurih. Camilan gurih pas untuk santap santai.';
      default:
        return 'Menu istimewa Piring Penuh yang diolah higienis menggunakan bahan-bahan segar pilihan dan resep khas nusantara untuk kenikmatan santap Anda.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = cekKetersediaanMenu(
      tersedia: widget.item.tersedia,
      porsiTersisa: widget.item.porsiTersisa,
    );

    final double totalHargaItem = hitungSubtotalMenu(
      harga: widget.item.harga,
      jumlahPorsi: _jumlahPorsi,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rincian Menu',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. FOTO BESAR DENGAN BADGE STATUS
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      color: const Color(0xFFDCFCE7),
                      child: widget.item.imageUrl.isNotEmpty
                          ? Image.asset(
                              widget.item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImageFallback(),
                            )
                          : _buildImageFallback(),
                    ),
                  ),
                  // Badge Kategori di Kiri Atas
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(widget.item.kategori),
                            size: 14,
                            color: const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.item.kategori,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge HABIS / TERSEDIA di Kanan Atas
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        isAvailable ? 'TERSEDIA' : 'HABIS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. KARTU INFORMASI UTAMA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.namaMenu,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        Text(
                          formatRupiah(widget.item.harga),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: isAvailable
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable
                              ? 'Porsi Tersisa: ${widget.item.porsiTersisa} porsi'
                              : 'Stok Habis',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28, color: Color(0xFFF3F4F6)),
                    const Text(
                      'Deskripsi Menu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getDeskripsiMenu(widget.item.namaMenu),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. PROMO SPESIAL (ATURAN USAHA 1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.discount_outlined,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diskon 10% Otomatis',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Beli 5 porsi atau lebih untuk menu ini dan dapatkan potongan harga langsung 10%!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. PENGATUR JUMLAH PORSI & SUBTOTAL
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _jumlahPorsi > 0
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jumlah Pesanan',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              formatRupiah(totalHargaItem),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            if (_jumlahPorsi >= 5) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '-10%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    JumlahPorsiCounter(
                      initialValue: _jumlahPorsi,
                      maxPorsi: widget.item.porsiTersisa,
                      isEnabled: isAvailable,
                      onChanged: _handlePorsiChanged,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. TOMBOL KEMBALI DENGAN PERUBAHAN TERSIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(
                    _jumlahPorsi > 0
                        ? 'Simpan Pesanan ($_jumlahPorsi porsi)'
                        : 'Selesai',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 56, color: Color(0xFF16A34A)),
          SizedBox(height: 8),
          Text(
            'Piring Penuh',
            style: TextStyle(
              color: Color(0xFF166534),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'minuman':
        return Icons.local_cafe;
      case 'camilan':
        return Icons.bakery_dining;
      default:
        return Icons.dinner_dining;
    }
  }
}
