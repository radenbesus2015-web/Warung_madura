import 'package:flutter/material.dart';
import '../models/menu_item.dart';

// ==========================================
// RINGKASAN ATAS (F3: FITUR PILIHAN)
// Menampilkan minimal dua angka yang dihitung dengan perulangan
// dan ikut berubah saat menyaring/mencari
// ==========================================

class RingkasanAtasBar extends StatelessWidget {
  final List<MenuItem> filteredMenu;
  final bool isDesktop;

  const RingkasanAtasBar({
    super.key,
    required this.filteredMenu,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    int totalPorsiTersedia = 0;
    for (final item in filteredMenu) {
      totalPorsiTersedia += item.porsiTersisa;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDCFCE7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF16A34A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Menampilkan ${filteredMenu.length} menu pilihan  •  Total $totalPorsiTersedia porsi tersedia',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
