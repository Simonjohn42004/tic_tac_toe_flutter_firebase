import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_bloc.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_event.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_state.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/model/game/game_status.dart';

class OfflineAIGameScreen extends StatefulWidget {
  const OfflineAIGameScreen({super.key});

  @override
  State<OfflineAIGameScreen> createState() => _OfflineAIGameScreenState();
}

class _OfflineAIGameScreenState extends State<OfflineAIGameScreen> {
  @override
  void initState() {
    super.initState();
    // Start AI game when screen initializes
    context.read<OfflineAIGameBloc>().add(StartAIGame());
  }

  // Helper to distinguish if it's human turn (human plays X)
  bool isHumanTurn(GameModel model) => model.currentPlayer == 'X';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: BlocConsumer<OfflineAIGameBloc, OfflineAIGameState>(
            listenWhen: (prev, current) =>
                current is OfflineAIGameInProgress ||
                current is OfflineAIGameFinished,
            listener: (context, state) async {
              if (state is OfflineAIGameInProgress) {
                final model = state.gameModel;
                if (model.gameStatus == GameStatus.inProgress &&
                    model.currentPlayer == 'O') {
                  // Delay AI move slightly to simulate "thinking"
                  await Future.delayed(const Duration(milliseconds: 300));
                  // AI move is triggered internally in the Bloc/provider after this delay
                }
              }
            },
            builder: (context, state) {
              if (state is OfflineAIGameInProgress) {
                final model = state.gameModel;
                final humanTurn = model.currentPlayer == 'X';

                return _buildGameUI(model, humanTurn);
              } else if (state is OfflineAIGameFinished) {
                final model = state.gameModel;
                final resultMessage = state.resultMessage;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resultMessage,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        itemBuilder: (context, index) => _buildCell(
                          context,
                          index,
                          model,
                          false,
                        ), // Game finished, disable taps
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => context.read<OfflineAIGameBloc>().add(
                          ResetAIGame(),
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
              }

              // Default: loading spinner
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF10CFFF)),
              );
            },
          ),
        ),
      ),
    );
  }

  // Extract UI building into separate method for clarity
  Widget _buildGameUI(GameModel model, bool humanTurn) {
    String statusText;
    switch (model.gameStatus) {
      case GameStatus.inProgress:
        statusText = humanTurn ? "Your turn (X)" : "AI's turn (O)";
        break;
      case GameStatus.finished:
        statusText = model.winner.isEmpty
            ? "It's a draw!"
            : (model.winner == 'X' ? "You won!" : "AI won!");
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
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) =>
                _buildCell(context, index, model, humanTurn),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int index,
    GameModel model,
    bool humanTurn,
  ) {
    final symbol = model.filledPos[index];
    final isClickable =
        model.gameStatus == GameStatus.inProgress &&
        symbol.isEmpty &&
        humanTurn;

    return GestureDetector(
      onTap: () {
        if (!isClickable) return;
        context.read<OfflineAIGameBloc>().add(MakeAIMove(index));
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
