import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';
import 'jumlah_porsi_counter.dart';

// =======================================================
// KOMPONEN STATELESS KUSTOM: MenuCard
// Berkas .dart tersendiri, seluruh datanya diterima lewat
// parameter bernama yang wajib diisi (required).
// =======================================================

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final int jumlahPesanan;
  final ValueChanged<int> onPorsiChanged;

  const MenuCard({
    super.key,
    required this.item,
    required this.jumlahPesanan,
    required this.onPorsiChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = cekKetersediaanMenu(
      tersedia: item.tersedia,
      porsiTersisa: item.porsiTersisa,
    );

    final double subtotal = hitungSubtotalMenu(
      harga: item.harga,
      jumlahPorsi: jumlahPesanan,
    );

    // Styling khusus jika menu tidak tersedia (Penanda: Redup + tulisan "HABIS")
    final Color cardBgColor = isAvailable ? Colors.white : Colors.grey.shade100;
    final double cardOpacity = isAvailable ? 1.0 : 0.65;

    return Opacity(
      opacity: cardOpacity,
      child: Card(
        elevation: isAvailable ? 2.5 : 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isAvailable
                ? (jumlahPesanan > 0 ? Colors.teal.shade300 : Colors.grey.shade200)
                : Colors.red.shade200,
            width: jumlahPesanan > 0 ? 1.5 : 1.0,
          ),
        ),
        color: cardBgColor,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian Atas: Kategori, Status & Nama Menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Baris Tag Kategori & Status Ketersediaan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item.kategori).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.kategori,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(item.kategori),
                          ),
                        ),
                      ),
                      if (!isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'HABIS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Sisa: ${item.porsiTersisa}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Nama Menu
                  Text(
                    item.namaMenu,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Harga Satuan
                  Text(
                    formatRupiah(item.harga),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),

              // Bagian Bawah: Diskon & Baris Kontrol Pesanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (jumlahPesanan >= 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        children: [
                          Icon(Icons.discount, size: 12, color: Colors.orange.shade800),
                          const SizedBox(width: 3),
                          Text(
                            'Diskon 10% diterapkan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Baris Kontrol Pesanan & Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stateful Counter
                      JumlahPorsiCounter(
                        initialValue: jumlahPesanan,
                        maxPorsi: item.porsiTersisa,
                        isEnabled: isAvailable,
                        onChanged: onPorsiChanged,
                      ),

                      // Subtotal per Menu
                      if (jumlahPesanan > 0)
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatRupiah(subtotal),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'makanan':
        return Colors.deepOrange;
      case 'minuman':
        return Colors.blue;
      case 'camilan':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }
}
