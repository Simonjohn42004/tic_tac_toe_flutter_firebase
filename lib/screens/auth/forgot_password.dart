import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback?
  onBackToLogin; // Optional callback to navigate back to login

  const ForgotPasswordScreen({super.key, this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _errorMessage;
  String? _infoMessage;

  void _submitReset() async {
    final email = _emailController.text.trim();

    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {});

    try {
      // TODO: Call your password reset API or Firebase Auth method here
      await Future.delayed(const Duration(seconds: 2)); // simulate network call

      setState(() {
        _infoMessage = 'Password reset email sent! Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send reset email. Please try again.';
      });
    } finally {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2E),
        elevation: 0,
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBackToLogin != null) {
              widget.onBackToLogin!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151F2E),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Forgot your password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Enter your registered email below and we will send you instructions to reset your password.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF232736),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                if (_infoMessage != null)
                  Text(
                    _infoMessage!,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 22),
                GlowingButton(label: 'Send Reset Email', onTap: _submitReset),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
