import 'package:tic_tac_toe/model/game/game_model.dart';

abstract class GameProvider {
  /// Stream of real-time game model updates
  Stream<GameModel?> get gameModelStream;

  /// Create a new game (returns the gameId or null if failed)
  Future<String?> createGame({required String myId});

  /// Join an existing game (returns true if join successful)
  Future<bool> joinGame({required String gameId, required String myId});

  /// Start the game (if business rules allow)
  Future<void> startGame();

  /// Make a move at [index] (cell 0..8)
  Future<void> makeMove(int index);

  /// Dispose of resources
  void dispose();

  String get myId;
}
