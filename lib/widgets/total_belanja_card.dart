import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';

// ==========================================
// CARD KIRI: TOTAL BELANJA & DETAIL PESANAN
// ==========================================

class TotalBelanjaCard extends StatelessWidget {
  final List<MapEntry<MenuItem, int>> orderedItems;
  final double subtotal;
  final double totalDiskon;
  final int totalPembayaran;
  final bool isDesktop;
  final VoidCallback onKembali;

  const TotalBelanjaCard({
    super.key,
    required this.orderedItems,
    required this.subtotal,
    required this.totalDiskon,
    required this.totalPembayaran,
    required this.isDesktop,
    required this.onKembali,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Hijau Muda: Total Belanja
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_outlined,
                              size: 18,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'Total Belanja',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${orderedItems.length} Menu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(totalPembayaran),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Judul Subbagian: Detail Pesanan
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Item Menu yang Dipesan
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedItems.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 18, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final item = orderedItems[index].key;
              final qty = orderedItems[index].value;
              final double itemSubtotal = (item.harga * qty).toDouble();
              final double itemDiskon =
                  hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: item.imageUrl.isNotEmpty
                          ? Image.asset(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _imagePlaceholder(),
                            )
                          : _imagePlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Detail Nama & Harga
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaMenu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qty x ${formatRupiah(item.harga)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (itemDiskon > 0)
                          Text(
                            'Diskon 10% (${formatRupiah(itemDiskon)})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF16A34A),
                            ),
                          )
                        else
                          const Text(
                            'Diskon 0%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Kolom Subtotal & Diskon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(itemSubtotal),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (itemDiskon > 0)
                        Text(
                          formatRupiah(itemDiskon),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        )
                      else
                        const Text(
                          'Rp 0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),

          // Rincian Subtotal, Diskon, Total
          _summaryRow('Subtotal', formatRupiah(subtotal)),
          const SizedBox(height: 8),
          _summaryRow(
            'Total Diskon',
            formatRupiah(totalDiskon),
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          _summaryRow(
            'Total Setelah Diskon',
            formatRupiah(totalPembayaran),
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Banner Info Pembulatan Rp500
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total pembayaran akan dibulatkan ke pecahan Rp 500 terdekat.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Kembali ke Ringkasan
          if (isDesktop) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onKembali,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4B5563),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text(
                'Kembali ke Ringkasan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF4B5563),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isBold ? const Color(0xFF1F2937) : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  static Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(
        Icons.restaurant,
        color: Color(0xFF9CA3AF),
        size: 20,
      ),
    );
  }
}
