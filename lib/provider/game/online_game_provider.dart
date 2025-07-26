import 'dart:async';
import 'package:logger/logger.dart';
import 'package:tic_tac_toe/model/game/game_data_firestore.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/model/game/game_status.dart';
import 'package:tic_tac_toe/provider/game/game_provider.dart';

class OnlineGameProvider implements GameProvider {
  final Logger _log = Logger();
  final StreamController<GameModel?> _gameModelController =
      StreamController<GameModel?>.broadcast();
  StreamSubscription<GameModel?>? _subscription;

  String? _gameId;
  String? _myId;

  @override
  Stream<GameModel?> get gameModelStream => _gameModelController.stream;

  @override
  Future<String?> createGame({required String myId}) async {
    _myId = myId;
    final gameId = (1000 + DateTime.now().millisecondsSinceEpoch % 9000)
        .toString();

    final model = GameModel.newGame(gameId: gameId)
      ..playerX = myId
      ..playerO = ""
      ..activePlayers = [myId]
      ..gameStatus = GameStatus.created
      ..currentPlayer = myId; // Let playerX always start

    _log.i("Creating new game: $gameId by player: $myId");
    await GameDataFirestore.saveGameModel(model);
    _gameId = gameId;
    _listen();
    return gameId;
  }

  @override
  Future<bool> joinGame({required String gameId, required String myId}) async {
    _log.i("Attempting to join game: $gameId as player: $myId");

    _myId = myId;
    final model = await GameDataFirestore.fetchGameModel(gameId);
    if (model == null) {
      _log.w("GameModel not found for ID: $gameId");
      return false;
    }

    // If both players are empty, no host/playerX, so joining is invalid
    if (model.playerX.isEmpty && model.playerO.isEmpty) {
      _log.w(
        "Both playerX and playerO are empty. Invalid game state for $gameId",
      );
      return false;
    }

    // Check if both slots are full - room is full
    if (model.playerX.isNotEmpty && model.playerO.isNotEmpty) {
      _log.w(
        "Both playerX (${model.playerX}) and playerO (${model.playerO}) are assigned. Room is full.",
      );
      return false;
    }

    // Assign to the empty player slot
    if (model.playerX.isEmpty) {
      _log.i("Assigning joining player to playerX");
      model.playerX = myId;
      if (!model.activePlayers.contains(myId)) {
        model.activePlayers.add(myId);
      }
    } else if (model.playerO.isEmpty) {
      _log.i("Assigning joining player to playerO");
      model.playerO = myId;
      if (!model.activePlayers.contains(myId)) {
        model.activePlayers.add(myId);
      }
    }

    model.gameStatus = GameStatus.joined;

    _log.d(
      "DEBUG: playerX = ${model.playerX}, playerO = ${model.playerO}, activePlayers = ${model.activePlayers}",
    );

    await GameDataFirestore.saveGameModel(model);

    _gameId = gameId;
    _listen();

    return true;
  }

  @override
  Future<void> startGame() async {
    await Future.delayed(Duration(milliseconds: 300));

    if (_gameId == null) {
      _log.w("startGame() called but _gameId is null");
      return;
    }

    final model = await GameDataFirestore.fetchGameModel(_gameId!);
    if (model == null) {
      _log.e("GameModel not found for startGame with ID: $_gameId");
      return;
    }

    _log.i("Attempting to start game: $_gameId");

    if (model.playerX.isNotEmpty &&
        model.playerO.isNotEmpty &&
        (model.gameStatus == GameStatus.joined ||
            model.gameStatus == GameStatus.finished)) {
      model.resetGame();

      _log.i(
        "Game $_gameId started. Player X: ${model.playerX}, Player O: ${model.playerO}",
      );
      _log.d("DEBUG: currentPlayer is set to ${model.currentPlayer}");

      await GameDataFirestore.saveGameModel(model);
    } else {
      _log.w(
        "⚠️ Game $_gameId cannot start - playerX: '${model.playerX}', playerO: '${model.playerO}', status: '${model.gameStatus}'",
      );
    }
  }

  @override
  Future<void> makeMove(int index) async {
    if (_gameId == null || _myId == null) {
      _log.w("makeMove() called but gameId or myId is null");
      return;
    }

    final model = await GameDataFirestore.fetchGameModel(_gameId!);
    if (model == null || model.gameStatus != GameStatus.inProgress) {
      _log.w("makeMove() failed - invalid game state for game $_gameId");
      return;
    }

    _log.d("DEBUG: Current player is ${model.currentPlayer}, My ID is $_myId");

    if (model.currentPlayer != _myId) {
      _log.w("Not $_myId's turn. Current turn: ${model.currentPlayer}");
      return;
    }

    if (model.filledPos[index] != "") {
      _log.w("Cell $index already filled in game $_gameId");
      return;
    }

    // Determine symbol and player's move queue
    final symbol = _myId == model.playerX ? "X" : "O";
    final playerMoves = _myId == model.playerX
        ? model.playerXMoves
        : model.playerOMoves;

    // Remove oldest move if the player already has 3 moves on the board
    if (playerMoves.length == 3) {
      final oldestMoveIndex = playerMoves.removeAt(0);
      model.filledPos[oldestMoveIndex] = "";
      _log.i(
        "Player $_myId exceeded max moves, removed oldest move at index $oldestMoveIndex",
      );
    }

    // Place new move
    model.filledPos[index] = symbol;
    playerMoves.add(index);
    _log.i(
      "Player $_myId made move at index $index with symbol $symbol in game $_gameId",
    );

    // Check for winner/draw
    final winner = _findWinner(model.filledPos);
    if (winner.isNotEmpty) {
      model.winner = winner;
      model.gameStatus = GameStatus.finished;
      _log.i("Game $_gameId won by $winner");
    } else if (!model.filledPos.contains("")) {
      model.winner = "";
      model.gameStatus = GameStatus.finished;
      _log.i("Game $_gameId ended in a draw");
    } else {
      model.currentPlayer = (model.currentPlayer == model.playerX)
          ? model.playerO
          : model.playerX;
      _log.d("DEBUG: Next turn for ${model.currentPlayer}");
    }

    await GameDataFirestore.saveGameModel(model);
  }

  void _listen() {
    _subscription?.cancel();
    if (_gameId == null) return;

    _log.d("Listening for updates on game: $_gameId");
    _subscription = GameDataFirestore.listenGameModel(_gameId!).listen((
      model,
    ) async {
      if (model != null) {
        if (_myId != null && !model.activePlayers.contains(_myId)) {
          model.activePlayers.add(_myId!);
          await GameDataFirestore.saveGameModel(model);
        }
        _log.d("DEBUG: Incoming model update:");
        _log.d("  gameId = ${model.gameId}");
        _log.d("  playerX = ${model.playerX}, playerO = ${model.playerO}");
        _log.d("  currentPlayer = ${model.currentPlayer}");
        _log.d("  myId = $_myId");
        _log.d("  gameStatus = ${model.gameStatus}");
        _log.d("  activePlayers = ${model.activePlayers}");
        _log.d("  filledPos = ${model.filledPos}");
      }

      _gameModelController.add(model);
    });
  }

  @override
  void dispose() {
    _log.i("Disposing OnlineGameProvider for game: $_gameId");
    _subscription?.cancel();
    _gameModelController.close();

    // Clean-up presence and room as needed
    if (_gameId != null && _myId != null) {
      (() async {
        final model = await GameDataFirestore.fetchGameModel(_gameId!);
        if (model == null) return; // Room already gone

        model.activePlayers.remove(_myId);
        if (model.playerO == _myId) {
          model.playerO = "";
        } else {
          model.playerX = "";
        }
        model.resetGame();

        if (model.activePlayers.isEmpty) {
          _log.i("No active players left. Deleting room: $_gameId");
          await GameDataFirestore.deleteGameModel(_gameId!);
        } else {
          await GameDataFirestore.saveGameModel(model);
          _log.i(
            "Player $_myId left. Remaining players: ${model.activePlayers}",
          );
        }
      })();
    }
  }

  @override
  String get myId => _myId ?? "";

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
}
