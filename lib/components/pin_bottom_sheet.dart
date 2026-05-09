import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Function(String) onConfirm;

  const PinSheet({
    super.key,
    required this.onConfirm,
    this.title = "Confirm PIN",
    this.subtitle,
  });

  static void show({
    required Function(String) onConfirm,
    String title = "Confirm PIN",
    String? subtitle,
  }) {
    Get.bottomSheet(
      PinSheet(onConfirm: onConfirm, title: title, subtitle: subtitle),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<PinSheet> {
  String _pin = "";

  void _onKeyTap(String val) {
    if (_pin.length < 4) {
      setState(() => _pin += val);
      if (_pin.length == 4) {
        Get.back(); // Auto-close on completion
        widget.onConfirm(_pin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E17) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.subtitle!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < _pin.length
                          ? const Color(0xFF014492)
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        index < _pin.length
                            ? const Color(0xFF014492)
                            : Colors.grey.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildPinPad(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPinPad(bool isDark) {
    return Column(
      children: [
        for (var row in [
          ["1", "2", "3"],
          ["4", "5", "6"],
          ["7", "8", "9"],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((n) => _btn(n, isDark)).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 65),
            _btn("0", isDark),
            SizedBox(
              width: 65,
              child: IconButton(
                onPressed:
                    () => setState(() {
                      if (_pin.isNotEmpty) {
                        _pin = _pin.substring(0, _pin.length - 1);
                      }
                    }),
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF014492),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _btn(String t, bool isDark) => InkWell(
    onTap: () => _onKeyTap(t),
    borderRadius: BorderRadius.circular(50),
    child: Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white10 : Colors.grey[100],
      ),
      child: Center(
        child: Text(
          t,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
