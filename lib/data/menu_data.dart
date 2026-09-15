import '../models/menu_item.dart';

// ==========================================
// DATA MENU PIRING PENUH (14 Item Sesuai Spesifikasi)
// Kategori: Makanan (6), Minuman (6), Camilan (2)
// Gambar: Lokal dari assets/images/menu/
// ==========================================

final List<MenuItem> dummyMenuList = [
  // --- MAKANAN ---
  const MenuItem(
    namaMenu: 'Rawon',
    kategori: 'Makanan',
    harga: 20000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/rawon.jpg',
  ),
  const MenuItem(
    namaMenu: 'Soto',
    kategori: 'Makanan',
    harga: 15000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/soto.jpg',
  ),
  const MenuItem(
    namaMenu: 'Ayam Bakar',
    kategori: 'Makanan',
    harga: 18000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/ayam_bakar.jpg',
  ),
  const MenuItem(
    namaMenu: 'Ayam Goreng',
    kategori: 'Makanan',
    harga: 12000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/ayam_goreng.jpg',
  ),
  const MenuItem(
    namaMenu: 'Ayam Geprek',
    kategori: 'Makanan',
    harga: 15000,
    tersedia: true,
    porsiTersisa: 25,
    imageUrl: 'assets/images/menu/ayam_geprek.jpg',
  ),
  const MenuItem(
    namaMenu: 'Bebek Bakar',
    kategori: 'Makanan',
    harga: 23000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/bebek_bakar.jpg',
  ),

  // --- MINUMAN ---
  const MenuItem(
    namaMenu: 'Es Teh',
    kategori: 'Minuman',
    harga: 4000,
    tersedia: true,
    porsiTersisa: 25,
    imageUrl: 'assets/images/menu/es_teh.jpg',
  ),
  const MenuItem(
    namaMenu: 'Teh Hangat',
    kategori: 'Minuman',
    harga: 3000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl: 'assets/images/menu/teh_hangat.jpg',
  ),
  const MenuItem(
    namaMenu: 'Es Jeruk',
    kategori: 'Minuman',
    harga: 7000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl: 'assets/images/menu/es_jeruk.jpg',
  ),
  const MenuItem(
    namaMenu: 'Jeruk Hangat',
    kategori: 'Minuman',
    harga: 5000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl: 'assets/images/menu/jeruk_hangat.jpg',
  ),
  const MenuItem(
    namaMenu: 'Kopi',
    kategori: 'Minuman',
    harga: 6000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl: 'assets/images/menu/kopi.jpg',
  ),
  const MenuItem(
    namaMenu: 'Soda Gembira',
    kategori: 'Minuman',
    harga: 10000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/soda_gembira.jpg',
  ),

  // --- CAMILAN ---
  const MenuItem(
    namaMenu: 'Onion Ring',
    kategori: 'Camilan',
    harga: 10000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/onion_ring.jpg',
  ),
  const MenuItem(
    namaMenu: 'Kentang Goreng',
    kategori: 'Camilan',
    harga: 12000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl: 'assets/images/menu/kentang_goreng.jpg',
  ),
];
