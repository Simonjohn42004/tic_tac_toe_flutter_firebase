import 'package:flutter/material.dart';

class GlowingDialog extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final List<Widget>? actions;
  final Color glowColor;
  final double glowSpread;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlowingDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.glowColor = const Color(0xFF10CFFF),
    this.glowSpread = 24,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.7),
                  blurRadius: glowSpread,
                  spreadRadius: 2,
                ),
              ],
            ),
            width: double.infinity,
            height: null,
          ),
          // Dialog content
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151F2E),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: glowColor, width: 2),
            ),
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  child: title,
                ),
                if (content != null) ...[
                  const SizedBox(height: 18),
                  DefaultTextStyle(
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    child: content!,
                  ),
                ],
                if (actions != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
