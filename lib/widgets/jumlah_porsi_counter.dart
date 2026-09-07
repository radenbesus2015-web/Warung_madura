import 'package:flutter/material.dart';

// =======================================================
// KOMPONEN STATEFUL: JumlahPorsi
// Nilainya berubah saat aplikasi berjalan melalui setState,
// dan perubahannya langsung terlihat di layar.
// =======================================================

class JumlahPorsiCounter extends StatefulWidget {
  final int initialValue;
  final int maxPorsi;
  final bool isEnabled;
  final ValueChanged<int> onChanged;

  const JumlahPorsiCounter({
    super.key,
    required this.initialValue,
    required this.maxPorsi,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  State<JumlahPorsiCounter> createState() => _JumlahPorsiCounterState();
}

class _JumlahPorsiCounterState extends State<JumlahPorsiCounter> {
  late int _jumlahPorsi;

  @override
  void initState() {
    super.initState();
    _jumlahPorsi = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant JumlahPorsiCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _jumlahPorsi = widget.initialValue;
    }
  }

  void _tambah() {
    if (!widget.isEnabled) return;
    // Aturan Usaha 3: Tidak boleh melebihi porsi yang tersisa
    if (_jumlahPorsi < widget.maxPorsi) {
      setState(() {
        _jumlahPorsi++;
      });
      widget.onChanged(_jumlahPorsi);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maksimal stok tersedia hanya ${widget.maxPorsi} porsi!',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
  }

  void _kurang() {
    if (!widget.isEnabled) return;
    if (_jumlahPorsi > 0) {
      setState(() {
        _jumlahPorsi--;
      });
      widget.onChanged(_jumlahPorsi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = widget.isEnabled && _jumlahPorsi > 0;
    final bool canIncrement = widget.isEnabled && _jumlahPorsi < widget.maxPorsi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: widget.isEnabled ? Colors.teal.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isEnabled ? Colors.teal.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Kurang
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: canDecrement ? _kurang : null,
            icon: Icon(
              Icons.remove_circle_outline,
              color: canDecrement ? Colors.teal.shade700 : Colors.grey.shade400,
            ),
          ),
          // Angka Jumlah Porsi
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$_jumlahPorsi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.isEnabled ? Colors.teal.shade900 : Colors.grey.shade500,
              ),
            ),
          ),
          // Tombol Tambah
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: canIncrement ? _tambah : null,
            icon: Icon(
              Icons.add_circle_outline,
              color: canIncrement ? Colors.teal.shade700 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
