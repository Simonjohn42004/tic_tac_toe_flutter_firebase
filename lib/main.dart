import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/firebase_options.dart';
import 'package:tic_tac_toe/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TicTacToeApp());
}

/// Root widget for the app
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      theme: ThemeData.dark(),
    );
  }
}
