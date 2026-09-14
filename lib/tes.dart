import 'package:flutter/material.dart';

class RingkasanPesananPage extends StatefulWidget {
  const RingkasanPesananPage({super.key});

  @override
  State<RingkasanPesananPage> createState() =>
      _RingkasanPesananPageState();
}

class _RingkasanPesananPageState
    extends State<RingkasanPesananPage> {
  final List<Pesanan> pesanan = [
    Pesanan(
      nama: 'Ayam Geprek',
      harga: 15000,
      jumlah: 5,
      stok: 25,
    ),
    Pesanan(
      nama: 'Es Teh',
      harga: 4000,
      jumlah: 2,
      stok: 15,
    ),
    Pesanan(
      nama: 'Rawon',
      harga: 20000,
      jumlah: 1,
      stok: 10,
    ),
    Pesanan(
      nama: 'Es Jeruk',
      harga: 7000,
      jumlah: 3,
      stok: 7,
    ),
  ];

  // =========================
  // PERHITUNGAN
  // =========================

  int get subtotal {
    return pesanan.fold(
      0,
      (total, item) => total + item.harga * item.jumlah,
    );
  }

  int get totalDiskon {
    return pesanan.fold(
      0,
      (total, item) {
        if (item.jumlah >= 5) {
          return total +
              ((item.harga * item.jumlah) * 10 ~/ 100);
        }

        return total;
      },
    );
  }

  int get totalBayar {
    return subtotal - totalDiskon;
  }

  // =========================
  // UBAH JUMLAH
  // =========================

  void tambahJumlah(Pesanan item) {
    if (item.jumlah < item.stok) {
      setState(() {
        item.jumlah++;
      });
    }
  }

  void kurangiJumlah(Pesanan item) {
    if (item.jumlah > 1) {
      setState(() {
        item.jumlah--;
      });
    } else {
      hapusPesanan(item);
    }
  }

  void hapusPesanan(Pesanan item) {
    setState(() {
      pesanan.remove(item);
    });
  }

  // =========================
  // FORMAT RUPIAH
  // =========================

  String rupiah(int angka) {
    String value = angka.toString();
    String result = '';

    int counter = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      result = value[i] + result;
      counter++;

      if (counter % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return 'Rp $result';
  }

  // =========================
  // BATALKAN PESANAN
  // =========================

  void konfirmasiPembatalan() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan Pesanan?'),
          content: const Text(
            'Semua pesanan yang sudah dipilih akan dikosongkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  pesanan.clear();
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),

      // =========================
      // HEADER
      // =========================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Color(0xFF16A34A),
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Piring Penuh',
                  style: TextStyle(
                    color: Color(0xFF19324A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sistem Kasir Restoran',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          const Icon(
            Icons.account_circle,
            color: Color(0xFF19324A),
          ),
          const SizedBox(width: 6),
          const Text(
            'Kasir',
            style: TextStyle(
              color: Color(0xFF19324A),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1000) {
            return _desktopLayout();
          }

          return _mobileLayout();
        },
      ),
    );
  }

  // =========================
  // DESKTOP
  // =========================

  Widget _desktopLayout() {
    return Row(
      children: [
        _sidebar(),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _orderList(),
                ),

                const SizedBox(width: 20),

                Expanded(
                  flex: 3,
                  child: _summaryCard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // MOBILE
  // =========================

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _orderList(),

          const SizedBox(height: 20),

          _summaryCard(),
        ],
      ),
    );
  }

  // =========================
  // SIDEBAR
  // =========================

  Widget _sidebar() {
    return Container(
      width: 220,
      color: const Color(0xFFF0FAF5),
      child: Column(
        children: [
          const SizedBox(height: 30),

          _sidebarItem(
            Icons.home,
            'Menu',
            false,
          ),

          _sidebarItem(
            Icons.shopping_cart,
            'Pesanan',
            true,
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String title,
    bool active,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      child: Material(
        color: active
            ? const Color(0xFF16A34A)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(
            icon,
            color: active
                ? Colors.white
                : const Color(0xFF526575),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : const Color(0xFF19324A),
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DAFTAR PESANAN
  // =========================

  Widget _orderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),

            const SizedBox(width: 5),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF19324A),
                  ),
                ),
                Text(
                  'Periksa kembali pesanan sebelum pembayaran.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _tableHeader(),

                const Divider(),

                if (pesanan.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Belum ada pesanan.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ...pesanan.map(
                    (item) => _orderItem(item),
                  ),

                const SizedBox(height: 15),

                _discountInfo(),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        label: const Text(
                          'Kembali ke Menu',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF16A34A),
                          side: const BorderSide(
                            color: Color(0xFF16A34A),
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            pesanan.isEmpty
                                ? null
                                : konfirmasiPembatalan,
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text(
                          'Batalkan Pesanan',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // HEADER TABEL
  // =========================

  Widget _tableHeader() {
    return const Row(
      children: [
        SizedBox(
          width: 35,
          child: Text(
            'No',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: Text(
            'Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Harga',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Jumlah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Subtotal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Diskon',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(width: 40),
      ],
    );
  }

  // =========================
  // ITEM PESANAN
  // =========================

  Widget _orderItem(Pesanan item) {
    final index = pesanan.indexOf(item) + 1;

    final subtotalItem =
        item.harga * item.jumlah;

    final diskonItem =
        item.jumlah >= 5
            ? subtotalItem * 10 ~/ 100
            : 0;

    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text('$index'),
          ),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF19324A),
                  ),
                ),

                Text(
                  'Stok: ${item.stok}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Text(
              rupiah(item.harga),
            ),
          ),

          Expanded(
            child: _quantityControl(item),
          ),

          Expanded(
            child: Text(
              rupiah(subtotalItem),
            ),
          ),

          Expanded(
            child: diskonItem > 0
                ? Text(
                    '${rupiah(diskonItem)}\n(10%)',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : const Text('-'),
          ),

          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () {
                hapusPesanan(item);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // QUANTITY
  // =========================

  Widget _quantityControl(Pesanan item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              kurangiJumlah(item);
            },
            icon: const Icon(
              Icons.remove,
              size: 18,
            ),
            color: const Color(0xFF16A34A),
          ),

          Text(
            '${item.jumlah}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          IconButton(
            onPressed: item.jumlah < item.stok
                ? () {
                    tambahJumlah(item);
                  }
                : null,
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            color: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  // =========================
  // INFO DISKON
  // =========================

  Widget _discountInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.percent,
            color: Color(0xFF16A34A),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Diskon 10% berlaku untuk setiap menu '
              'dengan jumlah minimal 5 porsi.',
              style: TextStyle(
                color: Color(0xFF087A3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SUMMARY CARD
  // =========================

  Widget _summaryCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8EF),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFF16A34A),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Total Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  '${pesanan.length} Menu',
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _summaryRow(
              'Subtotal',
              rupiah(subtotal),
            ),

            const SizedBox(height: 15),

            _summaryRow(
              'Total Diskon',
              rupiah(totalDiskon),
              green: true,
            ),

            const Divider(height: 30),

            _summaryRow(
              'Total Setelah Diskon',
              rupiah(totalBayar),
              bold: true,
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F0),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: Color(0xFF155E4B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    rupiah(totalBayar),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF19324A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Rincian Diskon',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...pesanan
                .where((item) => item.jumlah >= 5)
                .map(
                  (item) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.nama} (${item.jumlah} porsi)',
                          ),
                        ),
                        Text(
                          rupiah(
                            item.harga *
                                item.jumlah *
                                10 ~/
                                100,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF5),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Text(
                'Diskon hanya berlaku untuk menu '
                'yang jumlah pesanannya 5 porsi atau lebih.',
                style: TextStyle(
                  color: Color(0xFF087A3A),
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pesanan.isEmpty
                    ? null
                    : () {
                        // Nanti diarahkan ke halaman pembayaran.
                      },
                icon: const Icon(
                  Icons.payment,
                ),
                label: const Text(
                  'Lanjut ke Pembayaran',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool green = false,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  bold ? FontWeight.bold : null,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 17 : 15,
            fontWeight:
                bold ? FontWeight.bold : null,
            color: green
                ? const Color(0xFF16A34A)
                : const Color(0xFF19324A),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// MODEL PESANAN
// =====================================================

class Pesanan {
  String nama;
  int harga;
  int jumlah;
  int stok;

  Pesanan({
    required this.nama,
    required this.harga,
    required this.jumlah,
    required this.stok,
  });
}