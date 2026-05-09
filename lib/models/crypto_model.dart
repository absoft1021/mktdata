import 'package:flutter/material.dart';

class CryptoAsset {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final Color color;
  final IconData icon;

  CryptoAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.color,
    required this.icon,
  });
}