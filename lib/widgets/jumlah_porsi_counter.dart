import 'package:flutter/material.dart';

// =======================================================
// KOMPONEN STATEFUL: JumlahPorsiCounter
// Didesain modern sesuai UI Mockup Piring Penuh
// Warna utama: Hijau #16A34A
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
          backgroundColor: const Color(0xFFEF4444),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: widget.isEnabled ? const Color(0xFFF9FAFB) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isEnabled
              ? (_jumlahPorsi > 0 ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFE5E7EB))
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Kurang
          Material(
            color: canDecrement ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: canDecrement ? _kurang : null,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: canDecrement ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          // Angka Jumlah Porsi
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '$_jumlahPorsi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.isEnabled
                    ? (_jumlahPorsi > 0 ? const Color(0xFF16A34A) : const Color(0xFF1F2937))
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          // Tombol Tambah
          Material(
            color: canIncrement ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: canIncrement ? _tambah : null,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: canIncrement ? Colors.white : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
