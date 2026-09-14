import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'data/menu_data.dart';
import 'widgets/menu_card.dart';
import 'pages/ringkasan_pesanan_page.dart';
import 'utils/business_rules.dart';

void main() {
  runApp(const WarungApp());
}

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piring Penuh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          primary: const Color(0xFF16A34A),
        ),
        fontFamily: 'Roboto',
      ),
      home: const PiringPenuhHomeScreen(),
    );
  }
}

class PiringPenuhHomeScreen extends StatefulWidget {
  const PiringPenuhHomeScreen({super.key});

  @override
  State<PiringPenuhHomeScreen> createState() => _PiringPenuhHomeScreenState();
}

class _PiringPenuhHomeScreenState extends State<PiringPenuhHomeScreen> {
  // 1. Data Menu & Keranjang
  late List<MenuItem> _menuList;
  final Map<String, int> _cart = {};

  // 2. Kontrol Pencarian (Khas 2)
  late final TextEditingController _searchController;
  String _searchQuery = '';

  // 3. Fitur Pilihan (F2): Saring Kategori
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Camilan'];

  @override
  void initState() {
    super.initState();
    _menuList = List<MenuItem>.from(dummyMenuList);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter daftar menu berdasarkan pencarian & kategori pilihan (F2 & Khas 2)
  List<MenuItem> get _filteredMenu {
    return _menuList.where((item) {
      final matchQuery = item.namaMenu
          .toLowerCase()
          .contains(_searchQuery.trim().toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' ||
          item.kategori.toLowerCase() == _selectedCategory.toLowerCase();
      return matchQuery && matchCategory;
    }).toList();
  }

  // Hitung total porsi di keranjang
  int get _totalPorsi {
    return _cart.values.fold(0, (sum, count) => sum + count);
  }

  // Hitung total harga
  double get _totalHarga {
    double total = 0.0;
    _cart.forEach((namaMenu, jumlah) {
      if (jumlah > 0) {
        final item = _menuList.firstWhere(
          (m) => m.namaMenu == namaMenu,
          orElse: () => MenuItem(
            namaMenu: namaMenu,
            kategori: '',
            harga: 0,
            tersedia: false,
            porsiTersisa: 0,
          ),
        );
        total += hitungSubtotalMenu(harga: item.harga, jumlahPorsi: jumlah);
      }
    });
    return total;
  }

  // Callback saat counter porsi berubah
  void _onPorsiChanged(MenuItem item, int newPorsi) {
    setState(() {
      if (newPorsi <= 0) {
        _cart.remove(item.namaMenu);
      } else {
        _cart[item.namaMenu] = newPorsi;
      }
    });
  }

  // Callback setelah transaksi berhasil dibayar di Halaman 3
  void _handleTransaksiSelesai(Map<String, int> boughtItems) {
    setState(() {
      _menuList = _menuList.map((item) {
        if (boughtItems.containsKey(item.namaMenu)) {
          final int dibeli = boughtItems[item.namaMenu] ?? 0;
          final int sisaBaru = (item.porsiTersisa - dibeli).clamp(0, 999);
          return item.copyWith(
            porsiTersisa: sisaBaru,
            tersedia: sisaBaru > 0,
          );
        }
        return item;
      }).toList();
      _cart.clear();
    });
  }

  // Navigasi ke Halaman 2: Ringkasan Pesanan
  void _bukaRingkasanPesanan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RingkasanPesananPage(
          allMenus: _menuList,
          initialCart: _cart,
          onTransaksiSelesai: _handleTransaksiSelesai,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final isDesktop = screenConstraints.maxWidth >= 1000;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: _buildTopAppBar(isDesktop),
          body: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDesktopSidebar(),
                    Expanded(
                      child: _buildMainContent(isDesktop: true),
                    ),
                  ],
                )
              : _buildMainContent(isDesktop: false),
          bottomNavigationBar: !isDesktop && _totalPorsi > 0
              ? _buildMobileBottomBar()
              : null,
        );
      },
    );
  }

  // ==========================================
  // TOP APPBAR (Sesuai UI Bersih)
  // ==========================================
  PreferredSizeWidget _buildTopAppBar(bool isDesktop) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: isDesktop ? 24 : 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Color(0xFF16A34A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piring Penuh',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Sistem Kasir Restoran',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 20 : 16),
          child: isDesktop
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF9CA3AF),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kasir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                )
              : const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(
                    Icons.person,
                    size: 19,
                    color: Color(0xFF6B7280),
                  ),
                ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF3F4F6), height: 1),
      ),
    );
  }

  // ==========================================
  // SIDEBAR PERSIS TAMPILAN AWAL (DESKTOP)
  // ==========================================
  Widget _buildDesktopSidebar() {
    return Container(
      width: 220,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigasi Item: Menu (Hijau Solid)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.home, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Navigasi Item: Pesanan
          InkWell(
            onTap: _bukaRingkasanPesanan,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pesanan',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_totalPorsi > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _totalPorsi.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Box Hijau Bawah: Piring Penuh
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Piring Penuh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lezat dan Sehat\nSetiap Hari',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // KONTEN UTAMA:
  // Memenuhi Kerangka Wajib (Column -> TextField -> F2 -> Expanded -> LayoutBuilder -> GridView.builder)
  // Dilengkapi UI Rapi persis mockup awal
  // ==========================================
  Widget _buildMainContent({required bool isDesktop}) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Menu & Subtitle
            Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16,
                18,
                isDesktop ? 24 : 16,
                12,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pilih menu yang ingin dipesan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // 1. TextField Pencarian (Khas 2)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari menu...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 2. Kategori Chips (F2: Fitur Pilihan)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((kategori) {
                    final isSelected = _selectedCategory == kategori;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = kategori;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF16A34A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            kategori,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Expanded -> LayoutBuilder -> GridView.builder (Kerangka Wajib)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;

                  final int crossAxisCount;
                  final double childAspectRatio;
                  final bool isMobileHorizontal;

                  if (isDesktop) {
                    crossAxisCount = 3;
                    childAspectRatio = 1.05;
                    isMobileHorizontal = false;
                  } else if (width < 600) {
                    crossAxisCount = 1;
                    childAspectRatio = 3.6;
                    isMobileHorizontal = true;
                  } else {
                    crossAxisCount = 2;
                    childAspectRatio = 1.0;
                    isMobileHorizontal = false;
                  }

                  final filtered = _filteredMenu;

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 24 : 16,
                      isDesktop ? 0 : 8,
                      isDesktop ? 24 : 16,
                      isDesktop ? 80 : 88,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final int jumlah = _cart[item.namaMenu] ?? 0;
                      return MenuCard(
                        item: item,
                        jumlahPesanan: jumlah,
                        isHorizontal: isMobileHorizontal,
                        onPorsiChanged: (newVal) =>
                            _onPorsiChanged(item, newVal),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Floating Action Button "Lihat Pesanan" persis Mockup Awal (Desktop)
        if (isDesktop && _totalPorsi > 0)
          Positioned(
            right: 28,
            bottom: 24,
            child: InkWell(
              onTap: _bukaRingkasanPesanan,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _totalPorsi.toString(),
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Lihat Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Empty state jika pencarian kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Tidak ada menu yang cocok',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba cari dengan kata kunci lain atau pilih Semua',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM BAR MOBILE (KHAS 1)
  // ==========================================
  Widget _buildMobileBottomBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _bukaRingkasanPesanan,
            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
            label: Text(
              'Lihat Pesanan ($_totalPorsi)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
          ),
        ),
      ),
    );
  }
}
