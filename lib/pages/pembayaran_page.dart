import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';

// =======================================================
// HALAMAN 3: PEMBAYARAN (Piring Penuh)
// Sesuai Spesifikasi & UI Mockup Visual:
// - Layout Desktop (Sidebar, 2 Card: Total Belanja & Input)
// - Layout Mobile (Single-column card responsif)
// - Input uang pelanggan dengan format Rupiah
// - 6 Tombol nominal cepat (Rp 50k - Rp 250k)
// - Aturan pembulatan pecahan Rp500 terdekat
// - Validasi uang cukup vs tidak cukup (pesan error & tombol disabled)
// - Popup Struk Transaksi Berhasil & Pengurangan Stok
// =======================================================

class PembayaranPage extends StatefulWidget {
  final List<MenuItem> allMenus;
  final Map<String, int> cart;
  final void Function(Map<String, int> boughtItems)? onTransaksiSelesai;

  const PembayaranPage({
    super.key,
    required this.allMenus,
    required this.cart,
    this.onTransaksiSelesai,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  late final TextEditingController _uangController;
  int _jumlahUang = 0;

  // 6 Tombol nominal cepat sesuai spesifikasi
  final List<int> _nominalCepat = [
    50000,
    75000,
    100000,
    150000,
    200000,
    250000,
  ];

  @override
  void initState() {
    super.initState();
    _uangController = TextEditingController();
  }

  @override
  void dispose() {
    _uangController.dispose();
    super.dispose();
  }

  // Daftar item yang dipesan
  List<MapEntry<MenuItem, int>> get _orderedItems {
    final List<MapEntry<MenuItem, int>> items = [];
    for (var entry in widget.cart.entries) {
      if (entry.value > 0) {
        final menu = widget.allMenus.firstWhere(
          (m) => m.namaMenu == entry.key,
          orElse: () => MenuItem(
            namaMenu: entry.key,
            kategori: 'Makanan',
            harga: 0,
            tersedia: true,
            porsiTersisa: entry.value,
          ),
        );
        items.add(MapEntry(menu, entry.value));
      }
    }
    return items;
  }

  // Total porsi keseluruhan untuk badge sidebar
  int get _totalPorsiKeseluruhan {
    int total = 0;
    for (var qty in widget.cart.values) {
      total += qty;
    }
    return total;
  }

  // Subtotal kotor sebelum diskon
  double get _subtotal {
    double total = 0;
    for (var item in _orderedItems) {
      total += item.key.harga * item.value;
    }
    return total;
  }

  // Total diskon yang didapat
  double get _totalDiskon {
    double diskon = 0;
    for (var item in _orderedItems) {
      diskon += hitungDiskonItem(
        harga: item.key.harga,
        jumlahPorsi: item.value,
      );
    }
    return diskon;
  }

  // Total setelah diskon (sebelum pembulatan)
  double get _totalSetelahDiskon {
    return _subtotal - _totalDiskon;
  }

  // Total pembayaran setelah aturan pembulatan pecahan Rp500 terdekat
  int get _totalPembayaran {
    return bulatkanKePecahan500(_totalSetelahDiskon);
  }

  // Kembalian = Jumlah Uang - Total Pembayaran
  int get _kembalian {
    return _jumlahUang - _totalPembayaran;
  }

  // Kekurangan = Total Pembayaran - Jumlah Uang
  int get _kekurangan {
    return _totalPembayaran - _jumlahUang;
  }

  // Status kecukupan uang
  bool get _isUangCukup {
    return _totalPembayaran > 0 && _jumlahUang >= _totalPembayaran;
  }

  // Format angka ke Rupiah untuk textfield
  void _onUangInputChanged(String val) {
    String cleanDigits = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.isEmpty) {
      setState(() {
        _jumlahUang = 0;
        _uangController.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      });
      return;
    }

    int parsed = int.tryParse(cleanDigits) ?? 0;
    String formatted = formatRupiah(parsed);

    setState(() {
      _jumlahUang = parsed;
      _uangController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Handler klik tombol nominal cepat
  void _pilihNominalCepat(int nominal) {
    setState(() {
      _jumlahUang = nominal;
      String formatted = formatRupiah(nominal);
      _uangController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  // Selesaikan transaksi & tampilkan struk
  void _selesaikanTransaksi() {
    if (!_isUangCukup) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _buildStrukDialog(dialogCtx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1000) {
            return _buildDesktopLayout();
          }
          return _buildMobileLayout();
        },
      ),
    );
  }

  // ==========================================
  // APPBAR (RESPONSIF)
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo/piring_penuh.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.restaurant,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Piring Penuh',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sistem Kasir Restoran',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) {
            final isSmall = MediaQuery.of(context).size.width < 600;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 18, color: Color(0xFF4B5563)),
                ),
                if (!isSmall) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Kasir',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // LAYOUT DESKTOP (>= 1000px)
  // ==========================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Kiri
        _buildSidebar(),

        // Konten Pembayaran
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Navigasi & Judul
                _buildHeaderTitle(),
                const SizedBox(height: 20),

                // Dua Card Utama (Kiri: Total Belanja, Kanan: Input Pembayaran)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Kiri: Total Belanja & Detail Pesanan
                    Expanded(
                      flex: 5,
                      child: _buildTotalBelanjaCard(isDesktop: true),
                    ),
                    const SizedBox(width: 20),

                    // Card Kanan: Input Uang & Hasil Pembayaran
                    Expanded(
                      flex: 5,
                      child: _buildInputPembayaranCard(isDesktop: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LAYOUT MOBILE (< 600px)
  // ==========================================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Mobile
          _buildHeaderTitle(),
          const SizedBox(height: 16),

          // Card Total Belanja
          _buildTotalBelanjaCard(isDesktop: false),
          const SizedBox(height: 16),

          // Card Input Pembayaran
          _buildInputPembayaranCard(isDesktop: false),
        ],
      ),
    );
  }

  // Header Judul & Back Button
  Widget _buildHeaderTitle() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.chevron_left,
              size: 20,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Masukkan uang dari pelanggan dan selesaikan transaksi.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sidebar Desktop
  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _sidebarItem(
            icon: Icons.home,
            title: 'Menu',
            active: false,
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(height: 6),
          _sidebarItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Pesanan',
            active: true,
            badgeCount: _totalPorsiKeseluruhan,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          // Ilustrasi & Motto
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo/piring_penuh.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Piring Penuh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lezat dan Sehat\nSetiap Hari',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required bool active,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: active ? const Color(0xFF16A34A) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          dense: true,
          leading: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFF6B7280),
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF1F2937),
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: active ? const Color(0xFF16A34A) : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ==========================================
  // CARD KIRI: TOTAL BELANJA & DETAIL PESANAN
  // ==========================================
  Widget _buildTotalBelanjaCard({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Hijau Muda: Total Belanja
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_outlined,
                              size: 18,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Total Belanja',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_orderedItems.length} Menu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(_totalPembayaran),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Judul Subbagian: Detail Pesanan
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Item Menu yang Dipesan
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orderedItems.length,
            separatorBuilder: (context, index) => const Divider(height: 18, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final item = _orderedItems[index].key;
              final qty = _orderedItems[index].value;
              final double itemSubtotal = (item.harga * qty).toDouble();
              final double itemDiskon = hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: item.imageUrl.isNotEmpty
                          ? Image.asset(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Detail Nama & Harga
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaMenu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qty x ${formatRupiah(item.harga)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (itemDiskon > 0)
                          Text(
                            'Diskon 10% (${formatRupiah(itemDiskon)})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          )
                        else
                          const Text(
                            'Diskon 0%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Kolom Subtotal & Diskon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(itemSubtotal),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (itemDiskon > 0)
                        Text(
                          formatRupiah(itemDiskon),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        )
                      else
                        const Text(
                          'Rp 0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),

          // Rincian Subtotal, Diskon, Total
          _summaryRow('Subtotal', formatRupiah(_subtotal)),
          const SizedBox(height: 8),
          _summaryRow(
            'Total Diskon',
            formatRupiah(_totalDiskon),
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _summaryRow(
            'Total Setelah Diskon',
            formatRupiah(_totalPembayaran),
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Banner Info Pembulatan Rp500
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total pembayaran akan dibulatkan ke pecahan Rp 500 terdekat.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Kembali ke Ringkasan (jika di Desktop ditaruh di bawah Card Kiri)
          if (isDesktop) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4B5563),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text(
                'Kembali ke Ringkasan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // CARD KANAN: INPUT PEMBAYARAN & HASIL
  // ==========================================
  Widget _buildInputPembayaranCard({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Kanan
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Masukkan jumlah uang dari pelanggan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Label Input Uang
          const Text(
            'Jumlah Uang',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 6),

          // TextField Input Uang
          TextField(
            controller: _uangController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onUangInputChanged,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: 'Rp 0',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
              ),
              suffixIcon: _uangController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                      onPressed: () {
                        setState(() {
                          _jumlahUang = 0;
                          _uangController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // 6 Tombol Nominal Cepat (Grid 3x2)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: _nominalCepat.map((nominal) {
              final isSelected = _jumlahUang == nominal;
              return InkWell(
                onTap: () => _pilihNominalCepat(nominal),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF16A34A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatRupiah(nominal),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Card Hasil Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Hasil Pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _summaryRow(
                  'Total Belanja',
                  formatRupiah(_totalPembayaran),
                  fontSize: 12,
                ),
                const SizedBox(height: 6),
                _summaryRow(
                  'Jumlah Uang',
                  formatRupiah(_jumlahUang),
                  fontSize: 12,
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFDCFCE7)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      flex: 2,
                      child: Text(
                        'Kembalian',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _isUangCukup ? formatRupiah(_kembalian) : 'Rp 0',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Pesan Status (Hijau jika cukup, Merah jika kurang)
          if (_jumlahUang > 0 && !_isUangCukup) ...[
            // Status Uang Kurang
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uang pelanggan tidak cukup.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kekurangan: ${formatRupiah(_kekurangan)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_isUangCukup) ...[
            // Status Uang Cukup
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Uang pelanggan cukup. Transaksi dapat diselesaikan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Tombol Bayar Sekarang
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUangCukup ? _selesaikanTransaksi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.payment, size: 18),
              label: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Tombol Kembali untuk Mobile
          if (!isDesktop) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4B5563),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text(
                  'Kembali ke Ringkasan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // DIALOG POPUP STRUK TRANSAKSI
  // ==========================================
  Widget _buildStrukDialog(BuildContext dialogCtx) {
    final now = DateTime.now();
    final String tglFormatted =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Sukses
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF16A34A),
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PIRING PENUH',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Sistem Kasir Restoran • $tglFormatted',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              _dashedDivider(),
              const SizedBox(height: 12),

              // Rincian Item pada Struk
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderedItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _orderedItems[index].key;
                  final qty = _orderedItems[index].value;
                  final double itemSub = (item.harga * qty).toDouble();
                  final double itemDisk = hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.namaMenu,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(itemSub),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$qty x ${formatRupiah(item.harga)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (itemDisk > 0)
                            Text(
                              '-${formatRupiah(itemDisk)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _dashedDivider(),
              const SizedBox(height: 10),

              // Ringkasan Keuangan
              _strukRow('Subtotal', formatRupiah(_subtotal)),
              const SizedBox(height: 4),
              _strukRow(
                'Total Diskon',
                '-${formatRupiah(_totalDiskon)}',
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 4),
              _strukRow(
                'Total Pembayaran',
                formatRupiah(_totalPembayaran),
                isBold: true,
              ),
              const SizedBox(height: 6),
              _strukRow('Uang Pelanggan', formatRupiah(_jumlahUang)),
              const SizedBox(height: 4),
              _strukRow(
                'Kembalian',
                formatRupiah(_kembalian),
                isBold: true,
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 14),
              _dashedDivider(),
              const SizedBox(height: 14),

              const Text(
                'Terima kasih atas kunjungan Anda!',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Selesai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    // Panggil callback pengurangan stok & reset cart
                    widget.onTransaksiSelesai?.call(widget.cart);
                    // Kembali ke Halaman Menu utama
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Baris item ringkasan
  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF4B5563),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isBold ? const Color(0xFF1F2937) : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  // Baris pada struk
  Widget _strukRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF4B5563),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  // Garis putus-putus untuk struk
  Widget _dashedDivider() {
    return CustomPaint(
      painter: _DashedLinePainter(),
      size: const Size(double.infinity, 1),
    );
  }

  // Placeholder gambar jika gagal load
  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(
        Icons.restaurant,
        color: Color(0xFF9CA3AF),
        size: 20,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 4.0;
    const double dashSpace = 3.0;
    double startX = 0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
