import 'dart:async';

import 'package:tic_tac_toe/model/game_model.dart';
import 'package:tic_tac_toe/model/game_status.dart';
import 'package:tic_tac_toe/provider/game_provider.dart';

class OfflineGameProvider implements GameProvider {
  final StreamController<GameModel?> _gameModelController =
      StreamController<GameModel?>.broadcast();

  late GameModel _gameModel;

  GameModel? get currentGameModel => _gameModel;
  @override
  Stream<GameModel?> get gameModelStream => _gameModelController.stream;

  @override
  Future<String?> createGame({required String myId}) async {
    _gameModel = GameModel.newGame(gameId: "-1")
      ..playerX = "X"
      ..playerO = "O"
      ..currentPlayer = "X"
      ..gameStatus = GameStatus.joined;
    _gameModelController.add(_gameModel);
    return "-1";
  }

  @override
  Future<bool> joinGame({required String gameId, required String myId}) async {
    return true; // Offline join is no-op
  }

  @override
  Future<void> startGame() async {
    _gameModel.gameStatus = GameStatus.inProgress;
    _gameModel.filledPos = List.filled(9, '');
    _gameModel.winner = "";
    _gameModel.currentPlayer = "X";
    _gameModel.playerXMoves.clear();
    _gameModel.playerOMoves.clear();
    _gameModelController.add(_gameModel);
  }

  @override
  Future<void> makeMove(int index) async {
    if (_gameModel.gameStatus != GameStatus.inProgress) return;
    if (_gameModel.filledPos[index] != "") return;

    final currentPlayer = _gameModel.currentPlayer;
    List<int> playerMoves = currentPlayer == "X"
        ? _gameModel.playerXMoves
        : _gameModel.playerOMoves;

    // If player already has 3 moves, remove the oldest move from board
    if (playerMoves.length == 3) {
      int oldestMove = playerMoves.removeAt(0);
      _gameModel.filledPos[oldestMove] = "";
    }

    // Place new move
    _gameModel.filledPos[index] = currentPlayer;
    playerMoves.add(index);

    // Check for winner
    final winner = _findWinner(_gameModel.filledPos);
    if (winner != "") {
      _gameModel.winner = winner;
      _gameModel.gameStatus = GameStatus.finished;
    } else if (!_gameModel.filledPos.contains("")) {
      _gameModel.winner = "";
      _gameModel.gameStatus = GameStatus.finished;
    } else {
      // Switch turn
      _gameModel.currentPlayer = currentPlayer == "X" ? "O" : "X";
    }

    _gameModelController.add(_gameModel);
  }

  @override
  void dispose() {
    _gameModelController.close();
  }

  String _findWinner(List<String> board) {
    const wins = [
      [0, 1, 2], // rows
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6], // columns
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8], // diagonals
      [2, 4, 6],
    ];

    for (final pos in wins) {
      final String a = board[pos[0]];
      final String b = board[pos[1]];
      final String c = board[pos[2]];
      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }
    return "";
  }

  @override
  String get myId => "offline";
}
