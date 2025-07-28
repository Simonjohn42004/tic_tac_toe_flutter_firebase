import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_bloc.dart';
import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/bloc/auth/auth_state.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_bloc.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_bloc.dart';
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

  void _handleOnline() {
    debugPrint('[DEBUG] Play online clicked');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthStateUninitialized) {
                context.read<AuthBloc>().add(AuthEventInitialise());
              }
              print("[DEBUG] State is $state");
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
