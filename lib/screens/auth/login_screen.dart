import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleEmailLogin() async {
    setState(() => _isLoading = true);
    // TODO: Add your email/password login logic here
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    // TODO: Add your Google sign-in logic here
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _handleSignUp() {
    // TODO: Navigate to Sign Up screen or open dialog
  }

  void _handleForgotPassword() {
    // TODO: Trigger forgot password flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101B2B),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            color: const Color(0xFF151E2B),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF232736),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10CFFF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF10CFFF),
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF232736),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Elegant Row with simple TextButtons for Forgot Password and Sign Up
                  Row(
                    children: [
                      TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF10CFFF),
                          textStyle: const TextStyle(fontSize: 14),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _handleSignUp,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF10CFFF),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Glowing Login Button
                  GlowingButton(
                    label: _isLoading ? 'Logging in...' : 'Login',
                    onTap: _isLoading ? () {} : _handleEmailLogin,
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white38)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Glowing Google Sign-In Button
                  GlowingButton(
                    label: 'Sign in with Google',
                    onTap: _isLoading ? () {} : _handleGoogleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
