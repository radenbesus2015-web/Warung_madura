import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'data/menu_data.dart';
import 'widgets/menu_card.dart';
import 'pages/ringkasan_pesanan_page.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          primary: const Color(0xFF16A34A),
        ),
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
  late final TextEditingController _searchController;

  // Filter & Search State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final List<MenuItem> _allMenus = List<MenuItem>.from(dummyMenuList);

  // Cart State: namaMenu -> jumlah porsi
  final Map<String, int> _orderCart = {};

  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Camilan'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter menu berdasarkan pencarian & kategori
  List<MenuItem> get _filteredMenus {
    return _allMenus.where((menu) {
      final matchesSearch = menu.namaMenu.toLowerCase().contains(
            _searchQuery.toLowerCase().trim(),
          );
      final matchesCategory = _selectedCategory == 'Semua' ||
          menu.kategori.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Total Porsi dalam keranjang
  int get _totalPorsiKeseluruhan {
    int total = 0;
    for (var qty in _orderCart.values) {
      total += qty;
    }
    return total;
  }

  void _updateJumlahPesanan(MenuItem item, int newQty) {
    setState(() {
      if (newQty <= 0) {
        _orderCart.remove(item.namaMenu);
      } else {
        _orderCart[item.namaMenu] = newQty;
      }
    });
  }

  // Selesaikan Transaksi: Kurangi stok pada _allMenus & kosongkan cart
  void _selesaikanTransaksi(Map<String, int> boughtItems) {
    setState(() {
      for (int i = 0; i < _allMenus.length; i++) {
        final menu = _allMenus[i];
        final qtyDibeli = boughtItems[menu.namaMenu] ?? 0;
        if (qtyDibeli > 0) {
          final sisaBaru = (menu.porsiTersisa - qtyDibeli).clamp(0, 99999);
          _allMenus[i] = menu.copyWith(
            porsiTersisa: sisaBaru,
            tersedia: sisaBaru > 0,
          );
        }
      }
      _orderCart.clear();
    });
  }

  // Buka Halaman Ringkasan Pesanan & Sinkronkan Cart
  Future<void> _bukaHalamanRingkasan() async {
    final updatedCart = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (context) => RingkasanPesananPage(
          allMenus: _allMenus,
          initialCart: _orderCart,
          onTransaksiSelesai: _selesaikanTransaksi,
        ),
      ),
    );

    if (updatedCart != null) {
      setState(() {
        _orderCart.clear();
        _orderCart.addAll(updatedCart);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1000) {
            return _buildDesktopLayout(constraints);
          }
          return _buildMobileLayout(constraints);
        },
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
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF16A34A),
              size: 22,
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

  // Layout Desktop (Sidebar + Konten Grid)
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar
        _buildSidebar(),

        // Konten Menu
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Halaman
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pilih menu yang ingin dipesan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),

                // Baris Pencarian
                _buildSearchBar(),
                const SizedBox(height: 14),

                // Kategori Chips
                _buildCategoryChips(),
                const SizedBox(height: 18),

                // Grid Menu
                Expanded(
                  child: Stack(
                    children: [
                      _buildMenuGrid(constraints),

                      // Tombol Mengambang "Lihat Pesanan" di pojok kanan bawah
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _buildFloatingOrderButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Layout Mobile/Tablet (< 1000px)
  Widget _buildMobileLayout(BoxConstraints constraints) {
    final filtered = _filteredMenus;
    final bool isMobile = constraints.maxWidth < 600;
    final int totalJenisMenu = _orderCart.values.where((qty) => qty > 0).length;

    return Stack(
      children: [
        // Konten utama dengan padding bawah agar tidak tertutup sticky button
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, isMobile ? 0 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Pilih menu yang ingin dipesan',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 14),

              // List / Grid Menu
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : isMobile
                        ? ListView.builder(
                            // Padding bawah agar tidak tertutup sticky button
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final qty = _orderCart[item.namaMenu] ?? 0;
                              return MenuCard(
                                item: item,
                                jumlahPesanan: qty,
                                isHorizontal: true,
                                onPorsiChanged: (newQty) =>
                                    _updateJumlahPesanan(item, newQty),
                              );
                            },
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final qty = _orderCart[item.namaMenu] ?? 0;
                              return MenuCard(
                                item: item,
                                jumlahPesanan: qty,
                                onPorsiChanged: (newQty) =>
                                    _updateJumlahPesanan(item, newQty),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),

        // Sticky Bottom Button "Lihat Pesanan"
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bukaHalamanRingkasan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        totalJenisMenu > 0
                            ? 'Lihat Pesanan ($totalJenisMenu)'
                            : 'Lihat Pesanan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
            active: true,
            onTap: () {},
          ),
          const SizedBox(height: 6),
          _sidebarItem(
            icon: Icons.shopping_cart_outlined,
            title: 'Pesanan',
            active: false,
            badgeCount: _totalPorsiKeseluruhan,
            onTap: _bukaHalamanRingkasan,
          ),
          const Spacer(),

          // Ilustrasi & Motto di bagian bawah sidebar
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
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Color(0xFF16A34A),
                    size: 24,
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

  // Kotak Pencarian Sesuai Mockup
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // Kategori Chips Sesuai Mockup
  Widget _buildCategoryChips() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF16A34A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  // Grid Menu Desktop
  Widget _buildMenuGrid(BoxConstraints constraints) {
    final filtered = _filteredMenus;

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // Hitung jumlah kolom berdasarkan lebar ruang konten
    final double contentWidth = constraints.maxWidth - 220; // Dikurangi sidebar
    int crossAxisCount = 4;
    if (contentWidth < 800) {
      crossAxisCount = 2;
    } else if (contentWidth < 1100) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 70),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.76,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final qty = _orderCart[item.namaMenu] ?? 0;
        return MenuCard(
          item: item,
          jumlahPesanan: qty,
          onPorsiChanged: (newQty) => _updateJumlahPesanan(item, newQty),
        );
      },
    );
  }

  // Empty State jika pencarian tidak ditemukan
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            'Menu "$_searchQuery" tidak ditemukan',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kata kunci atau kategori lain',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // Tombol Mengambang "Lihat Pesanan" (Desktop)
  Widget _buildFloatingOrderButton() {
    final totalQty = _totalPorsiKeseluruhan;

    return ElevatedButton.icon(
      onPressed: _bukaHalamanRingkasan,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0xFF16A34A).withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Badge(
        isLabelVisible: totalQty > 0,
        label: Text('$totalQty'),
        backgroundColor: Colors.white,
        textColor: const Color(0xFF16A34A),
        child: const Icon(Icons.shopping_cart, size: 20),
      ),
      label: const Text(
        'Lihat Pesanan',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

