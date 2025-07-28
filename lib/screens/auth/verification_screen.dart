import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';

// Import your custom GlowingButton here

class VerificationPage extends StatelessWidget {
  final VoidCallback onResend;

  const VerificationPage({super.key, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 64, color: Color(0xFF10CFFF)),
              const SizedBox(height: 24),
              const Text(
                'A verification email has been sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              const Text(
                "If you don't see it, please check your spam or junk folder.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              GlowingButton(label: 'Resend Verification', onTap: onResend),
            ],
          ),
        ),
      ),
    );
  }
}
