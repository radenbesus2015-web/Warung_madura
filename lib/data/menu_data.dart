import '../models/menu_item.dart';

// ==========================================
// DATA MINIMAL: Minimal 8 baris data mandiri
// Kategori: Makanan, Minuman, Camilan
// ==========================================

final List<MenuItem> dummyMenuList = [
  const MenuItem(
    namaMenu: 'Nasi Rawon Daging Spesial',
    kategori: 'Makanan',
    harga: 25000,
    tersedia: true,
    porsiTersisa: 12,
  ),
  const MenuItem(
    namaMenu: 'Ayam Bakar Madu Pedas',
    kategori: 'Makanan',
    harga: 22000,
    tersedia: true,
    porsiTersisa: 8,
  ),
  const MenuItem(
    namaMenu: 'Soto Betawi Daging Sapi',
    kategori: 'Makanan',
    harga: 24000,
    tersedia: false, // Menandai menu habis/tidak tersedia
    porsiTersisa: 0,
  ),
  const MenuItem(
    namaMenu: 'Mie Goreng Seafood Jawa',
    kategori: 'Makanan',
    harga: 20000,
    tersedia: true,
    porsiTersisa: 6,
  ),
  const MenuItem(
    namaMenu: 'Es Teh Manis Melati Jumbo',
    kategori: 'Minuman',
    harga: 5000,
    tersedia: true,
    porsiTersisa: 25,
  ),
  const MenuItem(
    namaMenu: 'Es Jeruk Peras Segar',
    kategori: 'Minuman',
    harga: 7000,
    tersedia: true,
    porsiTersisa: 15,
  ),
  const MenuItem(
    namaMenu: 'Wedang Ronde Jahe Hangat',
    kategori: 'Minuman',
    harga: 12000,
    tersedia: false, // Menandai menu habis
    porsiTersisa: 0,
  ),
  const MenuItem(
    namaMenu: 'Tahu Walik Krispi Sambal Kecap',
    kategori: 'Camilan',
    harga: 10000,
    tersedia: true,
    porsiTersisa: 10,
  ),
  const MenuItem(
    namaMenu: 'Pisang Bakar Cokelat Keju',
    kategori: 'Camilan',
    harga: 14000,
    tersedia: true,
    porsiTersisa: 7,
  ),
  const MenuItem(
    namaMenu: 'Tempe Mendoan Purwokerto (3 pcs)',
    kategori: 'Camilan',
    harga: 9000,
    tersedia: true,
    porsiTersisa: 14,
  ),
];
