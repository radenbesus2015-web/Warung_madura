import 'package:flutter/material.dart';

// ==========================================
// SEARCH BOX: Kotak Pencarian Menu (Khas 2)
// ==========================================

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final bool isDesktop;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.isDesktop,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Cari menu...',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: isLandscape ? 8 : 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }
}
