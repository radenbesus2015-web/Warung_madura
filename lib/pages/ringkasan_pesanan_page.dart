import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';
import 'pembayaran_page.dart';

// =======================================================
// HALAMAN 2: Ringkasan Pesanan (Piring Penuh)
// Sesuai UI Mockup Lengkap:
// - Desain Desktop (Sidebar, Tabel Pesanan, Kartu Ringkasan)
// - Desain Mobile Responsif
// - Perhitungan Subtotal, Diskon 10% (>= 5 porsi), Total Bayar
// - Edit Porsi, Hapus Item, Batalkan Pesanan
// - Navigasi Sinkronisasi Cart kembali ke Halaman 1
// =======================================================

class RingkasanPesananPage extends StatefulWidget {
  final List<MenuItem> allMenus;
  final Map<String, int> initialCart;
  final void Function(Map<String, int> boughtItems)? onTransaksiSelesai;

  const RingkasanPesananPage({
    super.key,
    required this.allMenus,
    required this.initialCart,
    this.onTransaksiSelesai,
  });

  @override
  State<RingkasanPesananPage> createState() => _RingkasanPesananPageState();
}

class _RingkasanPesananPageState extends State<RingkasanPesananPage> {
  // Local state copy of cart so modifications can be tracked
  late Map<String, int> _cart;
  late final ScrollController _tableHorizontalScrollController;

  @override
  void initState() {
    super.initState();
    _cart = Map<String, int>.from(widget.initialCart);
    _tableHorizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tableHorizontalScrollController.dispose();
    super.dispose();
  }

  // List menu yang ada di cart
  List<MapEntry<MenuItem, int>> get _orderedItems {
    final List<MapEntry<MenuItem, int>> items = [];
    for (var entry in _cart.entries) {
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

  // Perhitungan Subtotal
  double get _subtotal {
    double total = 0;
    for (var item in _orderedItems) {
      total += item.key.harga * item.value;
    }
    return total;
  }

  // Perhitungan Total Diskon
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

  // Total Bayar setelah diskon
  double get _totalBayar {
    return _subtotal - _totalDiskon;
  }

  // Aksi Tambah Porsi
  void _tambahPorsi(MenuItem item) {
    final currentQty = _cart[item.namaMenu] ?? 0;
    if (currentQty < item.porsiTersisa) {
      setState(() {
        _cart[item.namaMenu] = currentQty + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${item.namaMenu} tersisa ${item.porsiTersisa} porsi!'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // Aksi Kurang Porsi
  void _kurangPorsi(MenuItem item) {
    final currentQty = _cart[item.namaMenu] ?? 0;
    if (currentQty > 1) {
      setState(() {
        _cart[item.namaMenu] = currentQty - 1;
      });
    } else {
      _hapusItem(item);
    }
  }

  // Aksi Hapus Item dari Cart
  void _hapusItem(MenuItem item) {
    setState(() {
      _cart.remove(item.namaMenu);
    });
  }

  // Konfirmasi Batalkan Seluruh Pesanan
  void _konfirmasiPembatalan() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Batalkan Pesanan?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Semua pesanan yang sudah dipilih akan dikosongkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _cart.clear();
                });
                Navigator.pop(ctx);
                Navigator.pop(context, _cart);
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  // Buka Halaman Pembayaran
  void _prosesPembayaran() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PembayaranPage(
          allMenus: widget.allMenus,
          cart: _cart,
          onTransaksiSelesai: widget.onTransaksiSelesai,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _cart);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1000) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  // App Bar Navigasi Sesuai Mockup
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 24,
      automaticallyImplyLeading: false,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE5E7EB),
              child: Icon(Icons.person, size: 18, color: Color(0xFF4B5563)),
            ),
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
            const SizedBox(width: 24),
          ],
        ),
      ],
    );
  }

  // Layout Desktop (Sidebar + Konten 2 Kolom)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Kiri
        _buildSidebar(),

        // Konten Tengah & Kanan
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Ringkasan Pesanan
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(context, _cart),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Periksa kembali pesanan Anda sebelum melakukan pembayaran.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grid 2 Kolom: Tabel Pesanan (kiri) & Kartu Ringkasan (kanan)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Tabel Pesanan
                    Expanded(
                      child: _buildOrderTableCard(),
                    ),
                    const SizedBox(width: 20),
                    // Kolom Kanan: Ringkasan & Pembayaran
                    SizedBox(
                      width: 310,
                      child: _buildSummaryCard(),
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

  // Layout Mobile (< 1000px)
  Widget _buildMobileLayout() {
    final items = _orderedItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Back + Judul
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context, _cart),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.only(top: 2, right: 8, bottom: 8),
                  child: Icon(
                    Icons.chevron_left,
                    size: 26,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Periksa kembali pesanan Anda sebelum melakukan pembayaran.',
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
          const SizedBox(height: 16),

          // Daftar Pesanan sebagai Card
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum ada menu yang dipilih.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Pilih Menu Sekarang'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index].key;
                final qty = items[index].value;
                return _buildMobileOrderItemCard(item, qty);
              },
            ),

          const SizedBox(height: 14),

          // Banner Diskon Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF16A34A),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Diskon 10% berlaku untuk setiap menu dengan jumlah minimal 5 porsi (per jenis menu).',
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

          const SizedBox(height: 16),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow('Subtotal', formatRupiah(_subtotal)),
                const SizedBox(height: 10),
                _summaryRow(
                  'Total Diskon',
                  formatRupiah(_totalDiskon),
                  valueColor: const Color(0xFF16A34A),
                ),
                const Divider(height: 20),
                _summaryRow(
                  'Total Setelah Diskon',
                  formatRupiah(_totalBayar),
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Card Total Pembayaran
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(_totalBayar),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rincian Diskon
          if (_orderedItems.any((e) => e.value >= 5)) ...[
            const Row(
              children: [
                Icon(Icons.discount_outlined, size: 16, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Text(
                  'Rincian Diskon',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._orderedItems.where((e) => e.value >= 5).map((e) {
              final diskon = hitungDiskonItem(
                harga: e.key.harga,
                jumlahPorsi: e.value,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${e.key.namaMenu} (${e.value} porsi)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(diskon),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Tombol Kembali ke Menu & Batalkan Pesanan (Row side-by-side)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, _cart),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text(
                    'Kembali ke Menu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: items.isEmpty ? null : _konfirmasiPembatalan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tombol Lanjut ke Pembayaran
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: items.isEmpty ? null : _prosesPembayaran,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.payment, size: 18),
              label: const Text(
                'Lanjut ke Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar Komponen
  Widget _buildSidebar() {
    return Container(
      width: 200,
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
            icon: Icons.home_outlined,
            title: 'Menu',
            active: false,
            onTap: () => Navigator.pop(context, _cart),
          ),
          const SizedBox(height: 6),
          _sidebarItem(
            icon: Icons.shopping_cart,
            title: 'Pesanan',
            active: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required bool active,
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
        ),
      ),
    );
  }

  // Kartu Tabel Pesanan (Kiri)
  Widget _buildOrderTableCard({bool isMobile = false}) {
    final items = _orderedItems;

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
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 54,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada menu yang dipilih.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, _cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Pilih Menu Sekarang'),
                    ),
                  ],
                ),
              ),
            )
          else if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = items[index].key;
                final qty = items[index].value;
                return _buildMobileOrderItemCard(item, qty);
              },
            )
          else
            LayoutBuilder(
              builder: (context, cardConstraints) {
                const double minTableWidth = 680.0;
                final double tableWidth = cardConstraints.maxWidth > minTableWidth
                    ? cardConstraints.maxWidth
                    : minTableWidth;
                return Scrollbar(
                  controller: _tableHorizontalScrollController,
                  thumbVisibility: cardConstraints.maxWidth < minTableWidth,
                  child: SingleChildScrollView(
                    controller: _tableHorizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTableHeader(),
                          const Divider(height: 24),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final item = items[index].key;
                              final qty = items[index].value;
                              return _buildDesktopOrderItem(index + 1, item, qty);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          // Banner Aturan Diskon Hijau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFF16A34A),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Diskon 10% berlaku untuk setiap menu dengan jumlah minimal 5 porsi (per jenis menu).',
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

          const SizedBox(height: 24),

          // Tombol Kembali & Batalkan Pesanan
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, _cart),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    side: const BorderSide(color: Color(0xFF16A34A)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text(
                    'Kembali ke Menu',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: items.isEmpty ? null : _konfirmasiPembatalan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Header Tabel Desktop
  Widget _buildTableHeader() {
    return const Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            'No',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        SizedBox(
          width: 95,
          child: Text(
            'Harga',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        SizedBox(
          width: 110,
          child: Center(
            child: Text(
              'Jumlah',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 105,
          child: Text(
            'Subtotal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        SizedBox(
          width: 95,
          child: Text(
            'Diskon',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Center(
            child: Text(
              'Aksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Row Item Pesanan Versi Desktop
  Widget _buildDesktopOrderItem(int index, MenuItem item, int qty) {
    final double subtotal = (item.harga * qty).toDouble();
    final double diskon = hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

    return Row(
      children: [
        // Nomor
        SizedBox(
          width: 36,
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),

        // Thumbnail & Nama Menu
        Expanded(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: item.imageUrl.isNotEmpty
                      ? Image.asset(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.namaMenu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok: ${item.porsiTersisa}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Harga
        SizedBox(
          width: 95,
          child: Text(
            formatRupiah(item.harga),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),

        // Jumlah Control
        SizedBox(
          width: 110,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _kurangPorsi(item),
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 14,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _tambahPorsi(item),
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Subtotal
        SizedBox(
          width: 105,
          child: Text(
            formatRupiah(subtotal),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),

        // Diskon
        SizedBox(
          width: 95,
          child: diskon > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatRupiah(diskon),
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      '(10%)',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : const Text(
                  '-',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
        ),

        // Tombol Hapus (Trash)
        SizedBox(
          width: 48,
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              tooltip: 'Hapus Menu',
              onPressed: () => _hapusItem(item),
            ),
          ),
        ),
      ],
    );
  }

  // Card Item Pesanan Versi Mobile (sesuai mockup)
  Widget _buildMobileOrderItemCard(MenuItem item, int qty) {
    final double subtotal = (item.harga * qty).toDouble();
    final double diskon = hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 58,
              child: item.imageUrl.isNotEmpty
                  ? Image.asset(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(width: 10),

          // Detail Menu (Nama, Harga, Stok)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  formatRupiah(item.harga),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok: ${item.porsiTersisa}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Bagian Kanan: Counter + Trash di atas, Subtotal & Diskon di bawah
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row Counter + Tombol Hapus (Trash)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Counter Pill: [- qty +]
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _kurangPorsi(item),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.remove,
                              size: 14,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _tambahPorsi(item),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Hapus (Trash merah border)
                  InkWell(
                    onTap: () => _hapusItem(item),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Subtotal Text
              Text(
                formatRupiah(subtotal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),

              // Diskon Text
              if (diskon > 0) ...[
                const Text(
                  'Diskon (10%)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  formatRupiah(diskon),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ] else
                const Text(
                  'Diskon -',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Kartu Ringkasan (Kanan)
  Widget _buildSummaryCard() {
    final items = _orderedItems;
    final discountedItems = items.where((e) => e.value >= 5).toList();

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
          // Header Total Pesanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Total Pesanan',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${items.length} Menu',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subtotal Row
          _summaryRow('Subtotal', formatRupiah(_subtotal)),
          const SizedBox(height: 10),

          // Diskon Row
          _summaryRow(
            'Total Diskon',
            formatRupiah(_totalDiskon),
            valueColor: const Color(0xFF16A34A),
          ),
          const Divider(height: 24),

          // Total Setelah Diskon
          _summaryRow(
            'Total Setelah Diskon',
            formatRupiah(_totalBayar),
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Highlight Card: Total Pembayaran
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(_totalBayar),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Rincian Diskon Section
          const Row(
            children: [
              Icon(Icons.discount_outlined, size: 18, color: Color(0xFF16A34A)),
              SizedBox(width: 6),
              Text(
                'Rincian Diskon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (discountedItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Tidak ada menu yang mendapat diskon.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            )
          else
            ...discountedItems.map((item) {
              final diskon = hitungDiskonItem(
                harga: item.key.harga,
                jumlahPorsi: item.value,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.key.namaMenu} (${item.value} porsi)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Text(
                      formatRupiah(diskon),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),

          // Box Info Aturan
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    'Diskon hanya berlaku untuk menu yang jumlahnya 5 atau lebih.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tombol Lanjut ke Pembayaran
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: items.isEmpty ? null : _prosesPembayaran,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.payment, size: 18),
              label: const Text(
                'Lanjut ke Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFDCFCE7),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          color: Color(0xFF16A34A),
          size: 20,
        ),
      ),
    );
  }
}
