import 'package:flutter/material.dart';

// ==========================================
// TOP APPBAR: Header aplikasi Piring Penuh
// ==========================================

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final bool isLandscapeMobile;

  const TopAppBar({
    super.key,
    required this.isDesktop,
    this.isLandscapeMobile = false,
  });

  double get _toolbarHeight =>
      isLandscapeMobile ? 44.0 : kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final logoSize = isLandscapeMobile ? 28.0 : 36.0;
    final titleSpacing = isLandscapeMobile ? 8.0 : (isDesktop ? 24.0 : 16.0);

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: _toolbarHeight,
      titleSpacing: titleSpacing,
      title: Row(
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo/piring_penuh.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF16A34A),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: isLandscapeMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Piring Penuh',
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: isLandscapeMobile ? 15 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (!isLandscapeMobile)
                const Text(
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
          padding: EdgeInsets.only(right: isDesktop ? 20 : 12),
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
