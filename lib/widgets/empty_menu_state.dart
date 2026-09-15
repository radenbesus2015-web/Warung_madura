import 'package:flutter/material.dart';

// ==========================================
// TAMPILAN KOSONG (F4: FITUR PILIHAN)
// Ikon dan kalimat yang memandu pengguna
// saat pencarian atau filter kosong
// ==========================================

class EmptyMenuState extends StatelessWidget {
  const EmptyMenuState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Tidak ada menu yang cocok',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba cari dengan kata kunci lain atau pilih Semua',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
