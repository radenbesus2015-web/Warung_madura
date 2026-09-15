import 'package:flutter/material.dart';

// ==========================================
// AKSI PESANAN: FAB Desktop & Bottom Bar Mobile (Khas 1)
// ==========================================

class DesktopLihatPesananFab extends StatelessWidget {
  final int totalPorsi;
  final VoidCallback onTap;

  const DesktopLihatPesananFab({
    super.key,
    required this.totalPorsi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPorsi <= 0) return const SizedBox.shrink();

    return Positioned(
      right: 28,
      bottom: 24,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        totalPorsi.toString(),
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                'Lihat Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileBottomBar extends StatelessWidget {
  final int totalPorsi;
  final VoidCallback onBukaPesanan;

  const MobileBottomBar({
    super.key,
    required this.totalPorsi,
    required this.onBukaPesanan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onBukaPesanan,
            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
            label: Text(
              'Lihat Pesanan ($totalPorsi)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
          ),
        ),
      ),
    );
  }
}
