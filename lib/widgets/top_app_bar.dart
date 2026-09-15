import 'package:flutter/material.dart';

// ==========================================
// TOP APPBAR: Header aplikasi Piring Penuh
// ==========================================

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;

  const TopAppBar({super.key, required this.isDesktop});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: isDesktop ? 24 : 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo/piring_penuh.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piring Penuh',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Sistem Kasir Restoran',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isDesktop ? 20 : 16),
          child: isDesktop
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF9CA3AF),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kasir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                )
              : const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(
                    Icons.person,
                    size: 19,
                    color: Color(0xFF6B7280),
                  ),
                ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF3F4F6), height: 1),
      ),
    );
  }
}
