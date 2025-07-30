import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_dialog.dart';

// Make sure to import your GlowingDialog here

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onOk;
  final Color glowColor;

  const ErrorDialog({
    super.key,
    this.title = "Error",
    required this.message,
    this.onOk,
    this.glowColor = const Color(0xFFFF335A), // Neon Pink/Red for error
  });

  @override
  Widget build(BuildContext context) {
    return GlowingDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: glowColor, size: 28),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(message),
      glowColor: glowColor,
      actions: [
        TextButton(
          onPressed: onOk ?? () => Navigator.of(context).maybePop(),
          child: const Text(
            "OK",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
