import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../utils/business_rules.dart';
import 'jumlah_porsi_counter.dart';

// =======================================================
// KOMPONEN STATELESS KUSTOM: MenuCard
// Didesain presisi sesuai Mockup "Piring Penuh"
// Menampilkan foto, nama, harga, stok, badge HABIS, dan counter
// =======================================================

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final int jumlahPesanan;
  final ValueChanged<int> onPorsiChanged;
  final bool isHorizontal;

  const MenuCard({
    super.key,
    required this.item,
    required this.jumlahPesanan,
    required this.onPorsiChanged,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = cekKetersediaanMenu(
      tersedia: item.tersedia,
      porsiTersisa: item.porsiTersisa,
    );

    final double cardOpacity = isAvailable ? 1.0 : 0.65;

    if (isHorizontal) {
      return _buildHorizontalCard(context, isAvailable, cardOpacity);
    }

    return _buildVerticalCard(context, isAvailable, cardOpacity);
  }

  // Tampilan Vertikal (Desktop & Tablet Grid)
  Widget _buildVerticalCard(
    BuildContext context,
    bool isAvailable,
    double cardOpacity,
  ) {
    return Opacity(
      opacity: cardOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: jumlahPesanan > 0
                ? const Color(0xFF16A34A).withValues(alpha: 0.6)
                : const Color(0xFFE5E7EB),
            width: jumlahPesanan > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Foto Makanan + Badge HABIS (Mengisi ruang sisa atas secara fleksibel)
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildImage(item.imageUrl),
                    ),
                  ),
                  if (!isAvailable)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
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
                      ),
                    ),
                ],
              ),
            ),

            // Informasi Menu (Ukuran pas alami, tidak akan overflow & jarak tombol counter konsisten)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.namaMenu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatRupiah(item.harga),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stok: ${item.porsiTersisa}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Counter kontrol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (jumlahPesanan >= 5)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '-10%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      JumlahPorsiCounter(
                        initialValue: jumlahPesanan,
                        maxPorsi: item.porsiTersisa,
                        isEnabled: isAvailable,
                        onChanged: onPorsiChanged,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan Horisontal (Mobile List)
  Widget _buildHorizontalCard(
    BuildContext context,
    bool isAvailable,
    double cardOpacity,
  ) {
    return Opacity(
      opacity: cardOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: jumlahPesanan > 0
                ? const Color(0xFF16A34A).withValues(alpha: 0.6)
                : const Color(0xFFE5E7EB),
            width: jumlahPesanan > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: _buildImage(item.imageUrl),
                    ),
                  ),
                  if (!isAvailable)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'HABIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Detail Menu
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaMenu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatRupiah(item.harga),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok: ${item.porsiTersisa}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Counter
              JumlahPorsiCounter(
                initialValue: jumlahPesanan,
                maxPorsi: item.porsiTersisa,
                isEnabled: isAvailable,
                onChanged: onPorsiChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Gambar dengan graceful fallback offline
  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF3F4F6),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8F8EF),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          color: Color(0xFF16A34A),
          size: 32,
        ),
      ),
    );
  }
}
