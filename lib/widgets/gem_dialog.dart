import 'package:flutter/material.dart';

class GemDialog extends StatelessWidget {
  final String icon, title, subtitle, confirmLabel;
  final Color confirmColor, confirmTextColor;
  final bool useGoldGradient;

  const GemDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.confirmColor,
    required this.confirmTextColor,
    this.useGoldGradient = false,
  });