import 'dart:collection';
import 'dart:math';
import 'package:logger/logger.dart';

class GameAI {
  final int maxDepth;
  final String aiSymbol; // "X" or "O"
  final String opponentSymbol;
  final Logger _logger = Logger();

  /// aiSymbol: "X" or "O". AI will maximize for this symbol.
  GameAI({this.maxDepth = 20, required this.aiSymbol})
    : opponentSymbol = aiSymbol == "X" ? "O" : "X";

  /// Alpha-beta search for Three Men's Morris (3 pieces max; oldest piece removal).
  Future<MapEntry<int?, int?>> alphaBetaPruning({
    required List<String> board,
    required bool isMaximizing,
    required int depth,
    required Queue<int> playerMoves,
    required Queue<int> opponentMoves,
    int alpha = -1000,
    int beta = 1000,
  }) async {
    final winner = _checkWinner(board);
    if (winner != null) {
      int score;
      if (winner == aiSymbol) {
        score = 50 - depth;
      } else if (winner == opponentSymbol) {
        score = -50 + depth;
      } else {
        score = 0;
      }
      _logger.d('Winner: $winner, Score: $score');
      return MapEntry(score, null);
    }

    if (depth >= maxDepth) {
      _logger.d('Max depth reached at depth $depth');
      return MapEntry(0, null);
    }

    String symbol = isMaximizing ? aiSymbol : opponentSymbol;
    Queue<int> movesQueue = Queue.from(playerMoves);
    Queue<int> opponentQueue = Queue.from(opponentMoves);
    int bestScore = isMaximizing ? -1000 : 1000;
    int? bestMove;

    // Determine game phase:
    bool isSlidingPhase = movesQueue.length >= 3;
    int forbiddenIndex = isSlidingPhase ? movesQueue.first : -1;

    for (int i = 0; i < 9; i++) {
      // Skip occupied cells
      if (board[i] != '') continue;

      // In sliding phase, forbid placing on the oldest piece's cell
      if (isSlidingPhase && i == forbiddenIndex) continue;

      // Make move
      board[i] = symbol;
      movesQueue.addLast(i);

      int? removed;
      if (isSlidingPhase && movesQueue.length > 3) {
        removed = movesQueue.removeFirst();
        board[removed] = '';
      }

      // Recursive call, swapping players and roles
      final result = await alphaBetaPruning(
        board: board,
        isMaximizing: !isMaximizing,
        depth: depth + 1,
        playerMoves: opponentQueue,
        opponentMoves: movesQueue,
        alpha: alpha,
        beta: beta,
      );

      // Undo move for backtracking
      if (removed != null) {
        board[removed] = symbol;
        movesQueue.addFirst(removed);
      }
      board[i] = '';

      int score = result.key ?? 0;

      if (isMaximizing) {
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
        alpha = max(alpha, bestScore);
      } else {
        if (score < bestScore) {
          bestScore = score;
          bestMove = i;
        }
        beta = min(beta, bestScore);
      }

      // Alpha-beta pruning
      if (beta <= alpha) {
        _logger.d('Pruned at depth $depth: α=$alpha, β=$beta');
        break;
      }
    }

    _logger.d(
      'Returning from depth $depth: BestMove=$bestMove, Score=$bestScore',
    );
    return MapEntry(bestScore, bestMove);
  }

  /// Check for winner on the board; returns symbol of winner or null if none
  String? _checkWinner(List<String> board) {
    final List<List<int>> winCombos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final combo in winCombos) {
      int a = combo[0], b = combo[1], c = combo[2];
      if (board[a] != '' && board[a] == board[b] && board[a] == board[c]) {
        return board[a];
      }
    }
    return null;
  }
}
