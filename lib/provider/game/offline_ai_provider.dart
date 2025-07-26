import 'dart:async';
import 'dart:collection';

import 'package:tic_tac_toe/model/ai_model/game_ai.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/model/game/game_status.dart';
import 'package:tic_tac_toe/provider/game/game_provider.dart';

class OfflineAIProvider implements GameProvider {
  final StreamController<GameModel?> _gameModelController =
      StreamController<GameModel?>.broadcast();

  late GameModel _gameModel;
  final String aiSymbol;
  late final String humanSymbol;
  late final GameAI _ai;

  OfflineAIProvider({this.aiSymbol = "O"}) {
    humanSymbol = aiSymbol == "X" ? "O" : "X";
    _ai = GameAI(aiSymbol: aiSymbol, maxDepth: 20);
  }

  @override
  Stream<GameModel?> get gameModelStream => _gameModelController.stream;

  @override
  String get myId => humanSymbol;

  GameModel? get currentGameModel => _gameModel;

  @override
  Future<String?> createGame({required String myId}) async {
    _gameModel = GameModel.newGame(gameId: "-1")
      ..playerX = "X"
      ..playerO = "O"
      ..currentPlayer = "X"
      ..gameStatus = GameStatus.joined
      ..playerXMoves.clear()
      ..playerOMoves.clear();
    _gameModelController.add(_gameModel);
    // If AI starts, make first move immediately.
    if (_gameModel.currentPlayer == aiSymbol) {
      await _makeAIMove();
    }
    return "-1";
  }

  @override
  Future<bool> joinGame({required String gameId, required String myId}) async {
    // Not relevant for offline AI mode, always true.
    return true;
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

    // If AI is to start, make AI's move
    if (_gameModel.currentPlayer == aiSymbol) {
      await _makeAIMove();
    }
  }

  @override
  Future<void> makeMove(int index) async {
    if (_gameModel.gameStatus != GameStatus.inProgress) return;
    if (_gameModel.filledPos[index] != "") return;
    if (_gameModel.currentPlayer != humanSymbol) return;

    // Human move logic
    await _placeMove(index, humanSymbol);

    // If game is not finished, let AI play automatically.
    if (_gameModel.gameStatus == GameStatus.inProgress &&
        _gameModel.currentPlayer == aiSymbol) {
      await _makeAIMove();
    }
  }

  Future<void> _placeMove(int index, String symbol) async {
    final movesQueue = symbol == "X"
        ? _gameModel.playerXMoves
        : _gameModel.playerOMoves;

    // Remove oldest move if already have 3
    if (movesQueue.length == 3) {
      final oldest = movesQueue.removeAt(0);
      _gameModel.filledPos[oldest] = '';
    }
    _gameModel.filledPos[index] = symbol;
    movesQueue.add(index);

    // Winner & draw check
    final winner = _findWinner(_gameModel.filledPos);
    if (winner != "") {
      _gameModel.winner = winner;
      _gameModel.gameStatus = GameStatus.finished;
    } else if (!_gameModel.filledPos.contains("")) {
      _gameModel.winner = "";
      _gameModel.gameStatus = GameStatus.finished;
    } else {
      // Switch turn
      _gameModel.currentPlayer = symbol == "X" ? "O" : "X";
    }

    _gameModelController.add(_gameModel);
  }

  Future<void> _makeAIMove() async {
    // Only proceed if it's AI's turn and game not over.
    if (_gameModel.gameStatus != GameStatus.inProgress ||
        _gameModel.currentPlayer != aiSymbol) {
      return;
    }

    final currentBoard = List<String>.from(_gameModel.filledPos);
    final aiMoves = aiSymbol == "X"
        ? Queue<int>.from(_gameModel.playerXMoves)
        : Queue<int>.from(_gameModel.playerOMoves);
    final humanMoves = humanSymbol == "X"
        ? Queue<int>.from(_gameModel.playerXMoves)
        : Queue<int>.from(_gameModel.playerOMoves);

    final result = await _ai.alphaBetaPruning(
      board: currentBoard,
      isMaximizing: true,
      depth: 0,
      playerMoves: aiMoves,
      opponentMoves: humanMoves,
    );
    final aiMove = result.value;
    if (aiMove != null) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Simulate thinking
      await _placeMove(aiMove, aiSymbol);
    }
  }

  String _findWinner(List<String> board) {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final pos in wins) {
      final s = board[pos[0]];
      if (s.isNotEmpty && s == board[pos[1]] && s == board[pos[2]]) return s;
    }
    return "";
  }

  @override
  void dispose() {
    _gameModelController.close();
  }
}
