import 'dart:math';
import 'package:tic_tac_toe/model/game/game_status.dart';

class GameModel {
  String gameId;
  List<String> filledPos;
  List<String> activePlayers; // NEW: track who is present
  String winner;
  GameStatus gameStatus;
  String currentPlayer;
  String playerX;
  String playerO;

  // Move tracking queues
  List<int> playerXMoves;
  List<int> playerOMoves;

  GameModel({
    required this.gameId,
    required this.filledPos,
    required this.activePlayers,
    required this.winner,
    required this.gameStatus,
    required this.currentPlayer,
    this.playerX = "X",
    this.playerO = "O",
    List<int>? playerXMoves,
    List<int>? playerOMoves,
  }) : playerXMoves = playerXMoves ?? [],
       playerOMoves = playerOMoves ?? [];

  /// Create a new game with default values.
  factory GameModel.newGame({required String gameId}) {
    final players = ["X", "O"];
    final currentPlayer = players[Random().nextInt(players.length)];
    return GameModel(
      gameId: gameId,
      filledPos: List.filled(9, ''),
      activePlayers: ["X"], // Host creates, only X present at first
      winner: '',
      gameStatus: GameStatus.created,
      currentPlayer: currentPlayer,
      playerX: "X",
      playerO: "O",
      playerXMoves: [],
      playerOMoves: [],
    );
  }

  /// Resets the game to a fresh state, clears moves and winner, randomizes starting player.
  void resetGame() {
    filledPos = List.filled(9, '');
    winner = '';
    playerXMoves.clear();
    playerOMoves.clear();
    // Pick random starter if both X and O present, otherwise keep current
    if (playerX.isNotEmpty && playerO.isNotEmpty) {
      currentPlayer = (Random().nextBool() ? playerX : playerO);
    }
    gameStatus = GameStatus.inProgress;
  }

  /// Serialize to Firestore-compatible map.
  Map<String, dynamic> toMap() => {
    'gameId': gameId,
    'filledPos': filledPos,
    'activePlayers': activePlayers,
    'winner': winner,
    'gameStatus': gameStatus.name,
    'currentPlayer': currentPlayer,
    'playerX': playerX,
    'playerO': playerO,
    'playerXMoves': playerXMoves,
    'playerOMoves': playerOMoves,
  };

  /// Deserialize from Firestore-compatible map.
  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map['gameId'] ?? "-1",
      filledPos: List<String>.from(map['filledPos'] ?? List.filled(9, '')),
      activePlayers: List<String>.from(map['activePlayers'] ?? []),
      winner: map['winner'] ?? "",
      gameStatus: GameStatus.values.firstWhere(
        (e) => e.name == (map['gameStatus'] ?? "created"),
        orElse: () => GameStatus.created,
      ),
      currentPlayer: map['currentPlayer'] ?? "X",
      playerX: map['playerX'] ?? "X",
      playerO: map['playerO'] ?? "O",
      playerXMoves: List<int>.from(map['playerXMoves'] ?? []),
      playerOMoves: List<int>.from(map['playerOMoves'] ?? []),
    );
  }
  @override
  String toString() {
    return 'GameModel(gameId: $gameId, playerX: $playerX, playerO: $playerO, currentPlayer: $currentPlayer, filledPos: $filledPos, winner: $winner, gameStatus: $gameStatus)';
  }
}
