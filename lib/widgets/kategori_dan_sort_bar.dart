import 'package:flutter/material.dart';

// ==========================================
// KATEGORI (F2) & SORT BAR (F1)
// ==========================================

class KategoriDanSortBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final String sortOption;
  final bool isDesktop;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSortSelected;

  const KategoriDanSortBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.sortOption,
    required this.isDesktop,
    required this.onCategorySelected,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double chipPadV = isLandscape ? 5 : 8;
    final double chipPadH = isLandscape ? 14 : 18;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...categories.map((kategori) {
              final isSelected = selectedCategory == kategori;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onCategorySelected(kategori),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: chipPadH,
                      vertical: chipPadV,
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
            }),
            // F1: Tombol Pilihan Urutkan
            PopupMenuButton<String>(
              tooltip: 'Urutkan Menu',
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: onSortSelected,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Default',
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted, size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 8),
                      Text('Urutan Standar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Harga: Termurah',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Text('Harga: Termurah'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Harga: Termahal',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 16, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text('Harga: Termahal'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Nama: A - Z',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Nama: A - Z'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Stok: Terbanyak',
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Text('Stok: Terbanyak'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: chipPadV,
                ),
                decoration: BoxDecoration(
                  color: sortOption != 'Default'
                      ? const Color(0xFFDCFCE7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sortOption != 'Default'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_vert,
                      size: 16,
                      color: sortOption != 'Default'
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sortOption == 'Default' ? 'Urutkan' : sortOption,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: sortOption != 'Default'
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: sortOption != 'Default'
                            ? const Color(0xFF166534)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: sortOption != 'Default'
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
