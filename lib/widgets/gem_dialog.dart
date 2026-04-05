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
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF13131f),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2a2a3e))),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    color: Color(0xFFf0d080),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5a5a72),
                    height: 1.5)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1e1e2e),
                        border: Border.all(color: const Color(0xFF2a2a3e)),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6b6b7e)))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: useGoldGradient ? null : confirmColor,
                      gradient: useGoldGradient
                          ? const LinearGradient(
                              colors: [Color(0xFFb8920e), Color(0xFFf0d080)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(confirmLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: confirmTextColor))),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}