import 'package:flutter/material.dart';

/// A custom elevated button with glowing, colored border (neon style)
class GlowingButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GlowingButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // Simulate a glowing effect using shadow
          BoxShadow(
            color: const Color(0xFF10CFFF).withOpacity(0.6),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // Text color
          elevation: 8,
          side: const BorderSide(color: Color(0xFF10CFFF), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
