import 'package:flutter/material.dart';
import 'package:tic_tac_toe/component/glowing_dialog.dart';

/// Handler to show the rules dialog
void showRulesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => GlowingDialog(
      title: const Text("Game Rules & Regulations"),
      content: const Text('''Tic Tac Toe (Three Men's Morris):

• Win by lining up 3 of your symbols (X or O) in a row, column, or diagonal.
• Each player may have at most 3 pieces on the board.
• If a player already has 3 pieces and tries to play a 4th, 
  their oldest piece is removed.
• You cannot place a symbol on a non-empty cell, or (when sliding) 
  on your own oldest piece.
• Play alternates between X and O.

Modes:
• Human vs Human: both tap to play X and O in turns.
• Human vs AI: you play as X, the computer plays as O.

First player to line up 3 wins! If all cells fill and nobody wins, it's a draw.
            '''),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Got it!"),
        ),
      ],
    ),
  );
}
