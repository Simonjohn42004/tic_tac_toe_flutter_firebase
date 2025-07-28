import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/bloc/auth/auth_state.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';
import 'package:tic_tac_toe/screens/auth/verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignInTap;

  const SignUpScreen({super.key, this.onSignInTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  String? _error;

  void _handleSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _error = null;
    });

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _error = "Please fill all fields.");
      return;
    }
    if (password != confirm) {
      setState(() => _error = "Passwords do not match.");
      return;
    }

    // Dispatch registration event to AuthBloc
    context.read<AuthBloc>().add(AuthEventRegister(email, password));
  }

  void _handleGoogleSignUp() {
    // TODO: Implement Google signup integration (if available)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-up not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateNeedsVerification) {
          // Navigate to verification page after successful registration
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VerificationPage(
                onResend: () {
                  context.read<AuthBloc>().add(
                    AuthEventSendEmailVerification(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email resent.')),
                  );
                },
              ),
            ),
          );
        } else if (state is AuthStateRegistering && state.exception != null) {
          setState(() {
            _error = state.exception.toString();
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF10141B),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF151E2B),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create your Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmController,
                      label: 'Confirm Password',
                      obscureText: !_isConfirmVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() {
                          _isConfirmVisible = !_isConfirmVisible;
                        }),
                      ),
                    ),
                    const SizedBox(height: 22),

                    GlowingButton(label: 'Sign Up', onTap: _handleSignUp),

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

                    GlowingButton(
                      label: 'Sign up with Google',
                      onTap: _handleGoogleSignUp,
                    ),

                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: widget.onSignInTap,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF10CFFF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF232736),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF10CFFF)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF10CFFF), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
