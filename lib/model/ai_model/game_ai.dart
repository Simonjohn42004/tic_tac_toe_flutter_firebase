import 'dart:collection';
import 'dart:math';

/// A Game AI class implementing Minimax with Alpha-Beta Pruning
/// for a variant of Tic Tac Toe similar to Three Men's Morris.
///
/// Rules considered:
/// - Each player can place up to 3 symbols.
/// - On the 4th move, the oldest symbol is removed.
/// - A symbol **cannot** be placed on the cell that's about to be removed on that move.
class GameAI {
  final int maxDepth;
  final String aiSymbol; // "X" or "O"
  final String opponentSymbol;

  /// Constructor for [GameAI]
  ///
  /// Takes [aiSymbol] ("X" or "O"), and an optional [maxDepth] to limit recursion depth.
  GameAI({this.maxDepth = 50, required this.aiSymbol})
    : opponentSymbol = aiSymbol == "X" ? "O" : "X";

  /// Executes Alpha-Beta Pruning and returns a MapEntry(score, bestMoveIndex)
  ///
  /// Parameters:
  /// - [board]: The current state of the game board
  /// - [isMaximizing]: Whether the AI is maximizing or minimizing
  /// - [depth]: Current recursive depth
  /// - [playerMoves]: Queue of moves made by current player
  /// - [opponentMoves]: Queue of moves made by the opponent
  /// - [maxDepth]: Optional override for max recursion
  ///
  /// Returns:
  /// - A MapEntry of (score, bestMoveIndex)
  MapEntry<int?, int?> alphaBetaPruning({
    required List<String> board,
    required bool isMaximizing,
    required int depth,
    required Queue<int> playerMoves,
    required Queue<int> opponentMoves,
    int maxDepth = 20,
    int alpha = -1000,
    int beta = 1000,
    required String aiSymbol,
    required String opponentSymbol,
  }) {
    // Check terminal condition - win/loss
    String? winner = _checkWinner(board);
    if (winner != null) {
      int score = (winner == aiSymbol) ? (50 - depth) : (-50 + depth);
      return MapEntry(score, null);
    }

    // Depth limit
    if (depth >= maxDepth) {
      return MapEntry(0, null);
    }

    final symbol = isMaximizing ? aiSymbol : opponentSymbol;
    final Queue<int> symbolMoves = Queue<int>.from(playerMoves);
    final Queue<int> oppSymbolMoves = Queue<int>.from(opponentMoves);

    final bool isSliding = symbolMoves.length >= 3;
    final int? forbiddenIndex = isSliding ? symbolMoves.first : null;

    int bestScore = isMaximizing ? -1000 : 1000;
    int? bestMove;
    bool anyMovePossible = false;

    for (int i = 0; i < 9; i++) {
      if (board[i] != '') continue;
      if (isSliding && i == forbiddenIndex) {
        continue;
      }

      anyMovePossible = true;

      // Simulate placing symbol
      board[i] = symbol;
      symbolMoves.addLast(i);

      int? removed;
      if (isSliding && symbolMoves.length > 3) {
        removed = symbolMoves.removeFirst();
        board[removed] = '';
      }

      // Recursive call
      final result = alphaBetaPruning(
        board: board,
        isMaximizing: !isMaximizing,
        depth: depth + 1,
        playerMoves: oppSymbolMoves,
        opponentMoves: symbolMoves,
        maxDepth: maxDepth,
        alpha: alpha,
        beta: beta,
        aiSymbol: aiSymbol,
        opponentSymbol: opponentSymbol,
      );

      // Undo move
      board[i] = '';
      symbolMoves.removeLast();
      if (removed != null) {
        board[removed] = symbol;
        symbolMoves.addFirst(removed);
      }

      int score = result.key ?? 0;
      if (isMaximizing ? score > bestScore : score < bestScore) {
        bestScore = score;
        bestMove = i;
      }

      if (isMaximizing) {
        alpha = max(alpha, bestScore);
      } else {
        beta = min(beta, bestScore);
      }

      if (beta <= alpha) {
        break;
      }
    }

    if (!anyMovePossible) {
      return MapEntry(0, null);
    }

    return MapEntry(bestScore, bestMove);
  }

  /// Checks if there is a winner on the board
  ///
  /// Returns:
  /// - "X" or "O" if there's a winner, null otherwise
  String? _checkWinner(List<String> board) {
    final winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a != '' && a == b && b == c) {
        return a;
      }
    }
    return null;
  }
}
