import 'package:flutter/material.dart';
import 'models/menu_item.dart';
import 'data/menu_data.dart';
import 'utils/app_theme.dart';
import 'widgets/top_app_bar.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/search_box.dart';
import 'widgets/kategori_dan_sort_bar.dart';
import 'widgets/ringkasan_atas_bar.dart';
import 'widgets/menu_grid_view.dart';
import 'widgets/pesanan_bottom_action.dart';
import 'pages/ringkasan_pesanan_page.dart';
import 'pages/rincian_menu_page.dart';

void main() => runApp(const WarungApp());

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piring Penuh',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
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
  late List<MenuItem> _menuList;
  final Map<String, int> _cart = {};

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _searchQuery = '';

  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Camilan'];
  String _sortOption = 'Default';

  @override
  void initState() {
    super.initState();
    _menuList = List<MenuItem>.from(dummyMenuList);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(skipTraversal: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<MenuItem> get _filteredMenu {
    final list = _menuList.where((item) {
      final matchQuery = item.namaMenu
          .toLowerCase()
          .contains(_searchQuery.trim().toLowerCase());
      final matchCategory =
          _selectedCategory == 'Semua' || item.kategori == _selectedCategory;
      return matchQuery && matchCategory;
    }).toList();

    switch (_sortOption) {
      case 'Harga: Termurah':
        list.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case 'Harga: Termahal':
        list.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case 'Nama: A - Z':
        list.sort((a, b) => a.namaMenu.compareTo(b.namaMenu));
        break;
      case 'Stok: Terbanyak':
        list.sort((a, b) => b.porsiTersisa.compareTo(a.porsiTersisa));
        break;
    }
    return list;
  }

  int get _totalPorsi => _cart.values.fold(0, (sum, count) => sum + count);

  void _onPorsiChanged(MenuItem item, int newPorsi) {
    setState(() {
      if (newPorsi <= 0) {
        _cart.remove(item.namaMenu);
      } else {
        final maxBoleh = item.porsiTersisa;
        _cart[item.namaMenu] = newPorsi > maxBoleh ? maxBoleh : newPorsi;
      }
    });
  }

  // Pengurangan stok menu saat transaksi pembayaran berhasil diselesaikan
  void _kurangiStokMenu(Map<String, int> boughtItems) {
    setState(() {
      for (int i = 0; i < _menuList.length; i++) {
        final item = _menuList[i];
        final qtyBought = boughtItems[item.namaMenu] ?? 0;
        if (qtyBought > 0) {
          final int sisaBaru = (item.porsiTersisa - qtyBought).clamp(0, 9999);
          _menuList[i] = item.copyWith(
            porsiTersisa: sisaBaru,
            tersedia: sisaBaru > 0,
          );
        }
      }
      _cart.clear();
    });
  }

  void _bukaRingkasanPesanan() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RingkasanPesananPage(
          allMenus: _menuList,
          initialCart: _cart,
          onTransaksiSelesai: _kurangiStokMenu,
        ),
      ),
    ).then((result) {
      if (mounted) {
        _searchFocusNode.unfocus();
        if (result is Map<String, int>) {
          setState(() {
            _cart.clear();
            _cart.addAll(result);
          });
        } else {
          setState(() {});
        }
      }
    });
  }

  void _bukaRincianMenu(MenuItem item) {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RincianMenuPage(
          item: item,
          initialPorsi: _cart[item.namaMenu] ?? 0,
          onPorsiChanged: (newVal) => _onPorsiChanged(item, newVal),
        ),
      ),
    ).then((_) {
      if (mounted) {
        _searchFocusNode.unfocus();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isLandscapeMobile =
            !isDesktop && orientation == Orientation.landscape;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: TopAppBar(
            isDesktop: isDesktop,
            isLandscapeMobile: isLandscapeMobile,
          ),
          body: GestureDetector(
            onTap: () {
              _searchFocusNode.unfocus();
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  DesktopSidebar(
                    totalPorsi: _totalPorsi,
                    onBukaPesanan: _bukaRingkasanPesanan,
                  ),
                Expanded(child: _buildMainContent(isDesktop)),
              ],
            ),
          ),
          bottomNavigationBar: !isDesktop && _totalPorsi > 0
              ? MobileBottomBar(
                  totalPorsi: _totalPorsi,
                  onBukaPesanan: _bukaRingkasanPesanan,
                )
              : null,
        );
      },
    );
  }


  // Kerangka Antarmuka Wajib: Column -> TextField -> F1/F2/F3 -> Expanded -> LayoutBuilder -> GridView
  Widget _buildMainContent(bool isDesktop) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscapeMobile = !isDesktop && orientation == Orientation.landscape;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16,
                isLandscapeMobile ? 8 : 18,
                isDesktop ? 24 : 16,
                isLandscapeMobile ? 6 : 12,
              ),
              child: isLandscapeMobile
                  ? const Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    )
                  : const Column(
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
                          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
            ),
            SearchBox(
              controller: _searchController,
              focusNode: _searchFocusNode,
              searchQuery: _searchQuery,
              isDesktop: isDesktop,
              onChanged: (val) => setState(() => _searchQuery = val),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
            SizedBox(height: isLandscapeMobile ? 8 : 14),
            KategoriDanSortBar(
              categories: _categories,
              selectedCategory: _selectedCategory,
              sortOption: _sortOption,
              isDesktop: isDesktop,
              onCategorySelected: (cat) {
                _searchFocusNode.unfocus();
                FocusScope.of(context).unfocus();
                setState(() => _selectedCategory = cat);
              },
              onSortSelected: (sort) {
                _searchFocusNode.unfocus();
                FocusScope.of(context).unfocus();
                setState(() => _sortOption = sort);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _searchFocusNode.unfocus();
                    FocusScope.of(context).unfocus();
                  }
                });
              },
            ),
            SizedBox(height: isLandscapeMobile ? 6 : 10),
            RingkasanAtasBar(
              filteredMenu: _filteredMenu,
              isDesktop: isDesktop,
            ),
            SizedBox(height: isLandscapeMobile ? 6 : 10),
            MenuGridView(
              items: _filteredMenu,
              cart: _cart,
              isDesktop: isDesktop,
              onTapItem: _bukaRincianMenu,
              onPorsiChanged: _onPorsiChanged,
            ),
          ],
        ),
        if (isDesktop)
          DesktopLihatPesananFab(
            totalPorsi: _totalPorsi,
            onTap: _bukaRingkasanPesanan,
          ),
      ],
    );
  }
}
