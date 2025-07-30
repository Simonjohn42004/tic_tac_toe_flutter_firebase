// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/bloc/auth/auth_state.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_bloc.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_bloc.dart';
import 'package:tic_tac_toe/component/loading/loading_screen.dart';
import 'package:tic_tac_toe/component/show_rules_dialog.dart';
import 'package:tic_tac_toe/provider/game/offline_ai_provider.dart';
import 'package:tic_tac_toe/provider/game/offline_game_provider.dart';
import 'package:tic_tac_toe/provider/game/online_game_provider.dart';
import 'package:tic_tac_toe/screens/auth/login_screen.dart';
import 'package:tic_tac_toe/screens/auth/online_home_page.dart';
import 'package:tic_tac_toe/screens/auth/sign_up_screen.dart';
import 'package:tic_tac_toe/screens/auth/verification_screen.dart';
import 'package:tic_tac_toe/screens/game/game_screen.dart';
import 'package:tic_tac_toe/screens/game/offline_ai_game_screen.dart'; // new import for AI screen
import 'package:tic_tac_toe/screens/game/offline_game_screen.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _roomId = '';

  void _handleOnline() async {
    debugPrint('[DEBUG] Play online clicked');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // 👈 Force Firebase to refresh user data
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        // Dispatch event to tell Bloc that user is now verified
        context.read<AuthBloc>().add(const AuthEventReload());
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BlocConsumer<AuthBloc, AuthState>(
            builder: (context, state) {
              debugPrint("[DEBUG] State is $state");

              if (state is AuthStateLoggedIn) {
                return const OnlineHomePage();
              } else if (state is AuthStateNeedsVerification) {
                return VerificationPage(
                  onResend: () {
                    context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
                  },
                );
              } else if (state is AuthStateLoggedOut) {
                return const LoginScreen();
              } else if (state is AuthStateRegistering) {
                return SignUpScreen();
              } else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
            listener: (BuildContext context, AuthState state) {
              print(
                "Entering the listerner with loading set to ${state.isLoading}",
              );
              if (state.isLoading) {
                LoadingScreen().show(
                  context: context,
                  text: state.loadingText ?? "Connecting....",
                );
              } else {
                LoadingScreen().hide();
              }
            },
          );
        },
      ),
    );
  }

  /// Navigate to Human vs Human offline game
  void _handleOfflineHumanVsHuman() {
    debugPrint('[DEBUG] Human vs Human Offline clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OfflineGameBloc(OfflineGameProvider()),
          child: const OfflineGameScreen(),
        ),
      ),
    );
  }

  /// Navigate to Human vs AI offline game
  void _handleOfflineHumanVsAI() {
    debugPrint('[DEBUG] Human vs AI Offline clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OfflineAIGameBloc(OfflineAIProvider(aiSymbol: 'O')),
          child: const OfflineAIGameScreen(),
        ),
      ),
    );
  }

  /// Navigate to online game (new room)
  void _handleNewRoom() {
    debugPrint('[DEBUG] Online Play clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GameBloc(provider: OnlineGameProvider()),
          child: const GameScreen(offlineMode: false),
        ),
      ),
    );
  }

  /// Navigate to join existing online room
  void _handleJoinRoom() {
    final id = _roomId.trim();
    debugPrint('[DEBUG] Entering room with ID: $id');
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid room ID')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GameBloc(provider: OnlineGameProvider()),
          child: GameScreen(roomId: id, offlineMode: false),
        ),
      ),
    );
  }

  @override
  void initState() {
    context.read<AuthBloc>().add(AuthEventInitialise());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tic Tac Toe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              GlowingButton(
                label: 'Play Offline',
                onTap: _handleOfflineHumanVsHuman,
              ),
              const SizedBox(height: 10),
              GlowingButton(
                label: 'Play with AI',
                onTap: _handleOfflineHumanVsAI,
              ),
              const SizedBox(height: 20),
              GlowingButton(label: 'Create Room', onTap: _handleNewRoom),
              const SizedBox(height: 32),
              SizedBox(
                width: 260,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter Room ID',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF232736),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF10CFFF),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF10CFFF),
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _roomId = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              GlowingButton(label: 'Enter Room', onTap: _handleJoinRoom),
              const SizedBox(height: 28),
              GlowingButton(label: "Play Online", onTap: _handleOnline),
              SizedBox(height: 20),
              GlowingButton(
                label: "Show Rules",
                onTap: () => showRulesDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
