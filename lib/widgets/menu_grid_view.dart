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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscapeMobile = !isDesktop && orientation == Orientation.landscape;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isPortraitMobile = !isDesktop && width < 500;

          final int crossAxisCount = isDesktop
              ? 3
              : isPortraitMobile
                  ? 1
                  : isLandscapeMobile
                      ? 2
                      : 2;

          final double childAspectRatio = isDesktop
              ? 1.05
              : isPortraitMobile
                  ? 3.6
                  : isLandscapeMobile
                      ? 3.3
                      : 1.0;

          final bool isMobileHorizontal = isPortraitMobile || isLandscapeMobile;

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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
