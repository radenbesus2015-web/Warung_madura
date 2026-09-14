import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warung_menu_app/main.dart';
import 'package:warung_menu_app/data/menu_data.dart';
import 'package:warung_menu_app/utils/business_rules.dart';
import 'package:warung_menu_app/models/menu_item.dart';
import 'package:warung_menu_app/pages/pembayaran_page.dart';

void main() {
  group('Pengujian Requirement Piring Penuh', () {
    testWidgets('Smoke test judul Piring Penuh', (WidgetTester tester) async {
      await tester.pumpWidget(const WarungApp());
      expect(find.text('Piring Penuh'), findsWidgets);
    });

    test('Validasi daftar 14 menu Piring Penuh (tidak ada Nasi Goreng & Mie Ayam)', () {
      expect(dummyMenuList.length, 14);

      final menuNames = dummyMenuList.map((m) => m.namaMenu).toList();
      expect(menuNames.contains('Nasi Goreng'), isFalse);
      expect(menuNames.contains('Mie Ayam'), isFalse);

      // Cek Makanan (6)
      expect(menuNames.contains('Rawon'), isTrue);
      expect(menuNames.contains('Soto'), isTrue);
      expect(menuNames.contains('Ayam Bakar'), isTrue);
      expect(menuNames.contains('Ayam Goreng'), isTrue);
      expect(menuNames.contains('Ayam Geprek'), isTrue);
      expect(menuNames.contains('Bebek Bakar'), isTrue);

      // Cek Minuman (6)
      expect(menuNames.contains('Es Teh'), isTrue);
      expect(menuNames.contains('Teh Hangat'), isTrue);
      expect(menuNames.contains('Es Jeruk'), isTrue);
      expect(menuNames.contains('Jeruk Hangat'), isTrue);
      expect(menuNames.contains('Kopi'), isTrue);
      expect(menuNames.contains('Soda Gembira'), isTrue);

      // Cek Camilan (2)
      expect(menuNames.contains('Onion Ring'), isTrue);
      expect(menuNames.contains('Kentang Goreng'), isTrue);
    });

    test('Uji Kasus 1: Ayam Geprek x 5 -> subtotal Rp75.000, diskon Rp7.500, total Rp67.500', () {
      const int hargaAyamGeprek = 15000;
      const int jumlah = 5;

      final double subtotal = (hargaAyamGeprek * jumlah).toDouble();
      final double diskon = hitungDiskonItem(harga: hargaAyamGeprek, jumlahPorsi: jumlah);
      final double total = subtotal - diskon;

      expect(subtotal, 75000.0);
      expect(diskon, 7500.0);
      expect(total, 67500.0);
    });

    test('Uji Kasus 2: Ayam Geprek x 10 -> subtotal Rp150.000, diskon Rp15.000, total Rp135.000', () {
      const int hargaAyamGeprek = 15000;
      const int jumlah = 10;

      final double subtotal = (hargaAyamGeprek * jumlah).toDouble();
      final double diskon = hitungDiskonItem(harga: hargaAyamGeprek, jumlahPorsi: jumlah);
      final double total = subtotal - diskon;

      expect(subtotal, 150000.0);
      expect(diskon, 15000.0);
      expect(total, 135000.0);
    });

    test('Uji Kasus 3: Ayam Geprek x 5 + Es Teh x 2 -> subtotal Rp83.000, diskon Rp7.500, total Rp75.500', () {
      const int hargaAyamGeprek = 15000;
      const int qtyGeprek = 5;
      const int hargaEsTeh = 4000;
      const int qtyEsTeh = 2;

      final double subtotalGeprek = (hargaAyamGeprek * qtyGeprek).toDouble();
      final double diskonGeprek = hitungDiskonItem(harga: hargaAyamGeprek, jumlahPorsi: qtyGeprek);

      final double subtotalEsTeh = (hargaEsTeh * qtyEsTeh).toDouble();
      final double diskonEsTeh = hitungDiskonItem(harga: hargaEsTeh, jumlahPorsi: qtyEsTeh);

      final double totalSubtotal = subtotalGeprek + subtotalEsTeh;
      final double totalDiskon = diskonGeprek + diskonEsTeh;
      final double totalBayar = totalSubtotal - totalDiskon;

      expect(totalSubtotal, 83000.0);
      expect(totalDiskon, 7500.0);
      expect(totalBayar, 75500.0);
    });

    test('Uji Aturan Pembulatan ke Pecahan Rp500 Terdekat', () {
      expect(bulatkanKePecahan500(30000), 30000);
      expect(bulatkanKePecahan500(30250), 30500);
      expect(bulatkanKePecahan500(30500), 30500);
      expect(bulatkanKePecahan500(30750), 31000);
      expect(bulatkanKePecahan500(75500), 75500);
      expect(bulatkanKePecahan500(75250), 75500);
      expect(bulatkanKePecahan500(75750), 76000);
    });

    testWidgets('Uji Halaman Pembayaran: Uang kurang vs Uang cukup, Struk, dan Pengurangan Stok',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testMenus = [
        const MenuItem(
          namaMenu: 'Ayam Geprek',
          kategori: 'Makanan',
          harga: 15000,
          tersedia: true,
          porsiTersisa: 10,
        ),
        const MenuItem(
          namaMenu: 'Es Teh',
          kategori: 'Minuman',
          harga: 4000,
          tersedia: true,
          porsiTersisa: 10,
        ),
      ];

      final Map<String, int> testCart = {
        'Ayam Geprek': 5, // Subtotal 75.000, diskon 7.500
        'Es Teh': 2,      // Subtotal 8.000, diskon 0
      }; // Total bayar = 75.500

      Map<String, int>? transaksiSelesaiItems;

      await tester.pumpWidget(
        MaterialApp(
          home: PembayaranPage(
            allMenus: testMenus,
            cart: testCart,
            onTransaksiSelesai: (items) {
              transaksiSelesaiItems = items;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cek judul dan total belanja tampil
      expect(find.text('Pembayaran'), findsWidgets);
      expect(find.text('Total Belanja'), findsWidgets);
      expect(find.text('Rp 75.500'), findsWidgets);

      // Cek tombol Bayar Sekarang awalnya disabled (karena belum ada input uang)
      final bayarButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Bayar Sekarang'));
      expect(bayarButton.onPressed, isNull);

      // Klik tombol nominal cepat Rp 50.000 (uang kurang)
      await tester.tap(find.text('Rp 50.000'));
      await tester.pumpAndSettle();

      // Pastikan pesan error uang tidak cukup muncul dan tombol tetap disabled
      expect(find.text('Uang pelanggan tidak cukup.'), findsOneWidget);
      expect(find.text('Kekurangan: Rp 25.500'), findsOneWidget);
      final bayarButtonKurang = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Bayar Sekarang'));
      expect(bayarButtonKurang.onPressed, isNull);

      // Klik tombol nominal cepat Rp 100.000 (uang cukup)
      await tester.tap(find.text('Rp 100.000'));
      await tester.pumpAndSettle();

      // Pastikan pesan sukses muncul, kembalian Rp 24.500, dan tombol aktif
      expect(find.text('Uang pelanggan cukup. Transaksi dapat diselesaikan.'), findsOneWidget);
      expect(find.text('Rp 24.500'), findsOneWidget);
      final bayarButtonCukup = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Bayar Sekarang'));
      expect(bayarButtonCukup.onPressed, isNotNull);

      // Tekan tombol Bayar Sekarang -> Muncul Struk Dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Bayar Sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Transaksi Berhasil!'), findsOneWidget);
      expect(find.text('PIRING PENUH'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      // Tekan tombol Selesai pada Struk
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      // Callback onTransaksiSelesai harus terpanggil membawa daftar item yang dibeli
      expect(transaksiSelesaiItems, isNotNull);
      expect(transaksiSelesaiItems!['Ayam Geprek'], 5);
      expect(transaksiSelesaiItems!['Es Teh'], 2);
    });

    testWidgets('Uji Responsive Mobile (<600px) Halaman Pembayaran tanpa overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testMenus = [
        const MenuItem(
          namaMenu: 'Rawon',
          kategori: 'Makanan',
          harga: 20000,
          tersedia: true,
          porsiTersisa: 15,
        ),
      ];
      final testCart = {'Rawon': 1};

      await tester.pumpWidget(
        MaterialApp(
          home: PembayaranPage(
            allMenus: testMenus,
            cart: testCart,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pastikan elemen mobile ter-render tanpa exception overflow
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('Total Belanja'), findsWidgets);
      expect(find.text('Rp 20.000'), findsWidgets);

      // Uji shortcut nominal cepat Rp 50.000
      await tester.ensureVisible(find.text('Rp 50.000'));
      await tester.tap(find.text('Rp 50.000'));
      await tester.pumpAndSettle();

      // Kembalian: 50.000 - 20.000 = 30.000
      expect(find.text('Rp 30.000'), findsOneWidget);
      expect(find.text('Uang pelanggan cukup. Transaksi dapat diselesaikan.'), findsOneWidget);
    });
  });
}


