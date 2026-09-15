import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'menu_card.dart';
import 'empty_menu_state.dart';

// ==========================================
// GRID DAFTAR MENU (KERANGKA WAJIB):
// Expanded -> LayoutBuilder -> GridView.builder -> MenuCard
// ==========================================

class MenuGridView extends StatelessWidget {
  final List<MenuItem> items;
  final Map<String, int> cart;
  final bool isDesktop;
  final ValueChanged<MenuItem> onTapItem;
  final void Function(MenuItem, int) onPorsiChanged;

  const MenuGridView({
    super.key,
    required this.items,
    required this.cart,
    required this.isDesktop,
    required this.onTapItem,
    required this.onPorsiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final int crossAxisCount = isDesktop ? 3 : (width < 600 ? 1 : 2);
          final double childAspectRatio =
              isDesktop ? 1.05 : (width < 600 ? 3.6 : 1.0);
          final bool isMobileHorizontal = !isDesktop && width < 600;

          if (items.isEmpty) return const EmptyMenuState();

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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MenuCard(
                item: item,
                jumlahPesanan: cart[item.namaMenu] ?? 0,
                isHorizontal: isMobileHorizontal,
                onTap: () => onTapItem(item),
                onPorsiChanged: (newVal) => onPorsiChanged(item, newVal),
              );
            },
          );
        },
      ),
    );
  }
}
