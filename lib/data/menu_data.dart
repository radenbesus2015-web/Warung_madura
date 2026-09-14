import '../models/menu_item.dart';

// ==========================================
// DATA MENU PIRING PENUH (14 Item Sesuai Spesifikasi)
// Kategori: Makanan (6), Minuman (6), Camilan (2)
// ==========================================

final List<MenuItem> dummyMenuList = [
  // --- MAKANAN ---
  const MenuItem(
    namaMenu: 'Rawon',
    kategori: 'Makanan',
    harga: 20000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Soto',
    kategori: 'Makanan',
    harga: 15000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1572656639666-054f483707ac?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Ayam Bakar',
    kategori: 'Makanan',
    harga: 18000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Ayam Goreng',
    kategori: 'Makanan',
    harga: 12000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Ayam Geprek',
    kategori: 'Makanan',
    harga: 15000,
    tersedia: true,
    porsiTersisa: 25,
    imageUrl:
        'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Bebek Bakar',
    kategori: 'Makanan',
    harga: 23000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1514944298352-bf62c00220d9?auto=format&fit=crop&w=600&q=80',
  ),

  // --- MINUMAN ---
  const MenuItem(
    namaMenu: 'Es Teh',
    kategori: 'Minuman',
    harga: 4000,
    tersedia: true,
    porsiTersisa: 25,
    imageUrl:
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Teh Hangat',
    kategori: 'Minuman',
    harga: 3000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Es Jeruk',
    kategori: 'Minuman',
    harga: 7000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Jeruk Hangat',
    kategori: 'Minuman',
    harga: 5000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1582293041079-7814c2f12063?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Kopi',
    kategori: 'Minuman',
    harga: 6000,
    tersedia: true,
    porsiTersisa: 20,
    imageUrl:
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Soda Gembira',
    kategori: 'Minuman',
    harga: 10000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=600&q=80',
  ),

  // --- CAMILAN ---
  const MenuItem(
    namaMenu: 'Onion Ring',
    kategori: 'Camilan',
    harga: 10000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1639024471285-0af50758e74a?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    namaMenu: 'Kentang Goreng',
    kategori: 'Camilan',
    harga: 12000,
    tersedia: true,
    porsiTersisa: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80',
  ),
];
