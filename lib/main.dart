import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'data/menu_data.dart';
import 'utils/business_rules.dart';
import 'widgets/menu_card.dart';

void main() {
  runApp(const WarungApp());
}

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Selera Nusantara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal.shade800,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const WarungHomeScreen(),
    );
  }
}

class WarungHomeScreen extends StatefulWidget {
  const WarungHomeScreen({super.key});

  @override
  State<WarungHomeScreen> createState() => _WarungHomeScreenState();
}

class _WarungHomeScreenState extends State<WarungHomeScreen> {
  // Controller pencarian diinisialisasi pada initState dan dibuang pada dispose
  late final TextEditingController _searchController;

  // State
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final List<MenuItem> _allMenus = dummyMenuList;

  // State Pesanan: Map index/namaMenu -> jumlah porsi yang dipesan
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

  // Filter menu berdasarkan query pencarian dan kategori terpilih
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

  // Hitung total harga seluruh pesanan (Tantangan Khas 1)
  double get _totalHargaKeseluruhan {
    double total = 0.0;
    for (var menu in _allMenus) {
      final int qty = _orderCart[menu.namaMenu] ?? 0;
      if (qty > 0) {
        total += hitungSubtotalMenu(harga: menu.harga, jumlahPorsi: qty);
      }
    }
    return total;
  }

  // Hitung total porsi item yang dipesan
  int get _totalPorsiKeseluruhan {
    int totalPorsi = 0;
    for (var qty in _orderCart.values) {
      totalPorsi += qty;
    }
    return totalPorsi;
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

  void _resetPesanan() {
    setState(() {
      _orderCart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daftar pesanan berhasil direset.'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredMenus;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warung Selera Nusantara',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Daftar Menu & Penghitung Pesanan Kasir',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_orderCart.isNotEmpty)
            IconButton(
              tooltip: 'Reset Pesanan',
              icon: const Icon(Icons.refresh),
              onPressed: _resetPesanan,
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Kotak Pencarian (Khas 2: menyaring berdasarkan nama menu)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama menu makanan / minuman...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.teal.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                ),
              ),
            ),
          ),

          // 2. [Bagian Pilihan: Fitur F2 - Saring Kategori]
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade700,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.teal.shade900,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.teal.shade700 : Colors.teal.shade100,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 3. Expanded > LayoutBuilder > GridView.builder (Ketentuan Responsif Seragam)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Aturan Responsif:
                // < 600 : 1 kolom
                // 600 - 899 : 2 kolom
                // >= 900 : 3 kolom
                int crossAxisCount = 1;
                double childAspectRatio = 2.0;

                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1;
                  // Memberi ruang vertikal yang cukup untuk kartu menu (mencegah overflow)
                  childAspectRatio = constraints.maxWidth > 420 ? 2.2 : (constraints.maxWidth > 350 ? 1.85 : 1.65);
                } else if (constraints.maxWidth <= 899) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.35;
                } else {
                  crossAxisCount = 3;
                  childAspectRatio = 1.3;
                }

                // Tampilan jika hasil pencarian atau filter kosong
                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Menu "$_searchQuery" tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Silakan coba kata kunci atau kategori lain',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final orderQty = _orderCart[item.namaMenu] ?? 0;

                    // Memanggil Komponen Stateless Kustom MenuCard
                    return MenuCard(
                      item: item,
                      jumlahPesanan: orderQty,
                      onPorsiChanged: (newQty) => _updateJumlahPesanan(item, newQty),
                    );
                  },
                );
              },
            ),
          ),

          // 4. [Tantangan Khas 1] Total Seluruh Pesanan pada bagian bawah layar
          _buildBottomSummaryBar(),
        ],
      ),
    );
  }

  Widget _buildBottomSummaryBar() {
    final double totalHarga = _totalHargaKeseluruhan;
    final int totalPorsi = _totalPorsiKeseluruhan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 16, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      'Total Pesanan ($totalPorsi porsi):',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(totalHarga),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: totalPorsi > 0
                  ? () {
                      _showCheckoutDialog(context, totalHarga, totalPorsi);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text(
                'Selesai Pesan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, double totalHarga, int totalPorsi) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.teal),
              SizedBox(width: 8),
              Text('Ringkasan Nota Pesanan'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar menu yang dipesan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ..._orderCart.entries.map((entry) {
                  final menu = _allMenus.firstWhere((m) => m.namaMenu == entry.key);
                  final sub = hitungSubtotalMenu(
                    harga: menu.harga,
                    jumlahPorsi: entry.value,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${entry.value}x ${menu.namaMenu}${entry.value >= 5 ? ' (Disc 10%)' : ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          formatRupiah(sub),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Bayar:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatRupiah(totalHarga),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _resetPesanan();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan berhasil diproses ke kasir!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Proses Bayar'),
            ),
          ],
        );
      },
    );
  }
}
