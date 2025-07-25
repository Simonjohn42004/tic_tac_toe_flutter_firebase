import 'dart:async';

import 'game_model.dart';
import 'game_data_firestore.dart';

class GameData {
  // Singleton instance
  static final GameData _instance = GameData._internal();
  factory GameData() => _instance;
  GameData._internal();

  /// Your current player ID ("X" or "O")
  static String myID = "";

  /// Stream controller to expose updates to GameModel
  final StreamController<GameModel?> _gameModelController =
      StreamController<GameModel?>.broadcast();

  Stream<GameModel?> get gameModelStream => _gameModelController.stream;

  /// Keep a reference to listen to Firestore real-time updates
  StreamSubscription<GameModel?>? _subscription;

  /// Subscribe to Firestore updates for a specific gameId
  void subscribeToGame(String gameId) {
    // Cancel previous subscription if any
    _subscription?.cancel();
    _subscription = GameDataFirestore.listenGameModel(gameId).listen((model) {
      _gameModelController.add(model);
    });
  }

  /// Cancel subscription when no longer needed
  void dispose() {
    _subscription?.cancel();
    _gameModelController.close();
  }
}
