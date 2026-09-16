import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';
import '../widgets/input_pembayaran_card.dart';
import '../widgets/struk_pembayaran_dialog.dart';
import '../widgets/total_belanja_card.dart';

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

  // Subtotal mentah sebelum diskon
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

  // Total setelah diskon masih yang mentah
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

    // Try-catch untuk memastikan parsing input nominal aman tanpa exception
    try {
      int parsed = int.parse(cleanDigits);
      String formatted = formatRupiah(parsed);

      setState(() {
        _jumlahUang = parsed;
        _uangController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      });
    } catch (e) {
      debugPrint('Error parsing input uang: $e');
    }
  }

  // Reset input uang
  void _clearUang() {
    setState(() {
      _jumlahUang = 0;
      _uangController.clear();
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

  // Selesaikan transaksi & tampilkan struk dengan try-catch dan if bertingkat/di dalam if
  void _selesaikanTransaksi() {
    try {
      // If tingkat 1: cek apakah total pembayaran valid
      if (_totalPembayaran > 0) {
        // If tingkat 2 (if di dalam if): cek apakah uang mencukupi
        if (_jumlahUang >= _totalPembayaran) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) => StrukPembayaranDialog(
              orderedItems: _orderedItems,
              subtotal: _subtotal,
              totalDiskon: _totalDiskon,
              totalPembayaran: _totalPembayaran,
              jumlahUang: _jumlahUang,
              kembalian: _kembalian,
              onSelesai: () {
                // Panggil callback pengurangan stok & reset cart
                widget.onTransaksiSelesai?.call(widget.cart);
                // Kembali ke Halaman Menu utama
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          );
        } else {
          // If bertingkat: uang kurang
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uang pembayaran masih kurang, silakan periksa kembali.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      // Penanganan error runtime
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kendala saat memproses transaksi: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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
                      child: TotalBelanjaCard(
                        orderedItems: _orderedItems,
                        subtotal: _subtotal,
                        totalDiskon: _totalDiskon,
                        totalPembayaran: _totalPembayaran,
                        isDesktop: true,
                        onKembali: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Card Kanan: Input Uang & Hasil Pembayaran
                    Expanded(
                      flex: 5,
                      child: InputPembayaranCard(
                        uangController: _uangController,
                        jumlahUang: _jumlahUang,
                        nominalCepat: _nominalCepat,
                        totalPembayaran: _totalPembayaran,
                        kembalian: _kembalian,
                        kekurangan: _kekurangan,
                        isUangCukup: _isUangCukup,
                        isDesktop: true,
                        onUangInputChanged: _onUangInputChanged,
                        onPilihNominalCepat: _pilihNominalCepat,
                        onClearUang: _clearUang,
                        onSelesaikanTransaksi: _selesaikanTransaksi,
                        onKembali: () => Navigator.pop(context),
                      ),
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
  // LAYOUT MOBILE (< 1000px)
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
          TotalBelanjaCard(
            orderedItems: _orderedItems,
            subtotal: _subtotal,
            totalDiskon: _totalDiskon,
            totalPembayaran: _totalPembayaran,
            isDesktop: false,
            onKembali: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),

          // Card Input Pembayaran
          InputPembayaranCard(
            uangController: _uangController,
            jumlahUang: _jumlahUang,
            nominalCepat: _nominalCepat,
            totalPembayaran: _totalPembayaran,
            kembalian: _kembalian,
            kekurangan: _kekurangan,
            isUangCukup: _isUangCukup,
            isDesktop: false,
            onUangInputChanged: _onUangInputChanged,
            onPilihNominalCepat: _pilihNominalCepat,
            onClearUang: _clearUang,
            onSelesaikanTransaksi: _selesaikanTransaksi,
            onKembali: () => Navigator.pop(context),
          ),
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
}
