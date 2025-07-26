import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_bloc.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_event.dart';
import 'package:tic_tac_toe/bloc/game/offline/offline_game_state.dart';
import 'package:tic_tac_toe/model/game_model.dart';
import 'package:tic_tac_toe/model/game_status.dart';

class OfflineGameScreen extends StatefulWidget {
  const OfflineGameScreen({super.key});

  @override
  State<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends State<OfflineGameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OfflineGameBloc>().add(StartOfflineGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: BlocBuilder<OfflineGameBloc, OfflineGameState>(
            builder: (context, state) {
              if (state is! OfflineGameInProgress) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10CFFF)),
                );
              }

              final model = state.gameModel;
              final isMyTurn = model.currentPlayer == 'X';

              String statusText;
              switch (model.gameStatus) {
                case GameStatus.inProgress:
                  statusText = "${isMyTurn ? "X" : "O"}'s turn";
                  break;
                case GameStatus.finished:
                  statusText = model.winner.isEmpty
                      ? "It's a draw!"
                      : "${model.winner} won!";
                  break;
                default:
                  statusText = "Starting game...";
              }

              return Column(
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Game board
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      itemCount: 9,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) =>
                          _buildCell(context, index, model),
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (model.gameStatus == GameStatus.finished)
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => context.read<OfflineGameBloc>().add(
                          ResetOfflineGame(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 8,
                          side: const BorderSide(
                            color: Color(0xFF10CFFF),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shadowColor: const Color(0xFF10CFFF),
                        ),
                        child: const Text(
                          "Play Again",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int index, GameModel model) {
    final symbol = model.filledPos[index];
    final isClickable =
        model.gameStatus == GameStatus.inProgress && symbol.isEmpty;

    return GestureDetector(
      onTap: () {
        if (isClickable) {
          context.read<OfflineGameBloc>().add(MakeOfflineMove(index));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10CFFF), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10CFFF).withOpacity(0.6),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Color(0xFF10CFFF),
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
