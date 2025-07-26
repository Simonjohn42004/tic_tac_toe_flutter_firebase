import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_bloc.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_bloc.dart';
import 'package:tic_tac_toe/provider/offline_game_provider.dart';
import 'package:tic_tac_toe/provider/online_game_provider.dart';
import 'package:tic_tac_toe/screens/game_screen.dart';
import 'package:tic_tac_toe/component/glowing_button.dart';
import 'package:tic_tac_toe/screens/offline_game_screen.dart';

/// MainPage:
/// - Displays three primary actions (offline, online, room join)
/// - Handles room ID input and navigates with appropriate GameBloc injection
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _roomId = '';

  /// Handles Play Offline button: navigate with OfflineGameProvider
  void _handlePlayOffline() {
    debugPrint('[DEBUG] Play Offline button clicked');
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

  /// Handles Play Online button: navigate with OnlineGameProvider (new room)
  void _handlePlayOnline() {
    debugPrint('[DEBUG] Play Online button clicked');
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

  /// Handles Room ID input change
  void _handleRoomIdChanged(String value) {
    debugPrint("[DEBUG] Room ID changed to '$value'");
    setState(() => _roomId = value);
  }

  /// Handles Enter Room button: navigate with OnlineGameProvider joining existing room
  void _handleEnterRoom() {
    final id = _roomId.trim();
    debugPrint("[DEBUG] Enter Room with ID: '$id'");

    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a room ID")));
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
              GlowingButton(label: 'Play Offline', onTap: _handlePlayOffline),
              const SizedBox(height: 20),
              GlowingButton(label: 'Play Online', onTap: _handlePlayOnline),
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
                  onChanged: _handleRoomIdChanged,
                ),
              ),
              const SizedBox(height: 16),
              GlowingButton(label: 'Enter Room', onTap: _handleEnterRoom),
            ],
          ),
        ),
      ),
    );
  }
}
