import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';

// ==========================================
// POPUP DIALOG STRUK TRANSAKSI PEMBAYARAN
// ==========================================

class StrukPembayaranDialog extends StatelessWidget {
  final List<MapEntry<MenuItem, int>> orderedItems;
  final double subtotal;
  final double totalDiskon;
  final int totalPembayaran;
  final int jumlahUang;
  final int kembalian;
  final VoidCallback onSelesai;

  const StrukPembayaranDialog({
    super.key,
    required this.orderedItems,
    required this.subtotal,
    required this.totalDiskon,
    required this.totalPembayaran,
    required this.jumlahUang,
    required this.kembalian,
    required this.onSelesai,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String tglFormatted =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Sukses
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF16A34A),
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PIRING PENUH',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Sistem Kasir Restoran • $tglFormatted',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              _dashedDivider(),
              const SizedBox(height: 12),

              // Rincian Item pada Struk
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderedItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = orderedItems[index].key;
                  final qty = orderedItems[index].value;
                  final double itemSub = (item.harga * qty).toDouble();
                  final double itemDisk =
                      hitungDiskonItem(harga: item.harga, jumlahPorsi: qty);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.namaMenu,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(itemSub),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$qty x ${formatRupiah(item.harga)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (itemDisk > 0)
                            Text(
                              '-${formatRupiah(itemDisk)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _dashedDivider(),
              const SizedBox(height: 10),

              // Ringkasan Keuangan
              _strukRow('Subtotal', formatRupiah(subtotal)),
              const SizedBox(height: 4),
              _strukRow(
                'Total Diskon',
                '-${formatRupiah(totalDiskon)}',
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 4),
              _strukRow(
                'Total Pembayaran',
                formatRupiah(totalPembayaran),
                isBold: true,
              ),
              const SizedBox(height: 6),
              _strukRow('Uang Pelanggan', formatRupiah(jumlahUang)),
              const SizedBox(height: 4),
              _strukRow(
                'Kembalian',
                formatRupiah(kembalian),
                isBold: true,
                color: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 14),
              _dashedDivider(),
              const SizedBox(height: 14),

              const Text(
                'Terima kasih atas kunjungan Anda!',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Selesai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onSelesai,
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _strukRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF4B5563),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  static Widget _dashedDivider() {
    return CustomPaint(
      painter: _DashedLinePainter(),
      size: const Size(double.infinity, 1),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 4.0;
    const double dashSpace = 3.0;
    double startX = 0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
