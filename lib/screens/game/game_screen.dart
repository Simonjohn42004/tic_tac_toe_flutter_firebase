import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_event.dart';
import 'package:tic_tac_toe/bloc/game/online/game_state.dart';
import 'package:tic_tac_toe/model/game/game_data.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/model/game/game_status.dart';

class GameScreen extends StatefulWidget {
  final String? roomId;
  final bool offlineMode;

  const GameScreen({super.key, this.roomId, required this.offlineMode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<GameBloc>();

    if (widget.offlineMode) {
      debugPrint('[DEBUG] Creating offline game...');
      bloc.add(CreateGame(offline: true));
    } else if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      debugPrint('[DEBUG] Joining online game with roomId: ${widget.roomId}');
      bloc.add(JoinGame(widget.roomId!));
    } else {
      debugPrint('[DEBUG] Creating new online game...');
      bloc.add(CreateGame(offline: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              final model = state.gameModel;

              if (model == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10CFFF)),
                );
              }

              final isOffline = widget.offlineMode;

              // Game status message
              String statusText;
              switch (model.gameStatus) {
                case GameStatus.created:
                  statusText = "Waiting for player to join...";
                  break;
                case GameStatus.joined:
                  statusText = "Click 'Start Game' to begin";
                  break;
                case GameStatus.inProgress:
                  statusText = model.currentPlayer == GameData.myID
                      ? "Your turn"
                      : "Opponent's turn";
                  break;
                case GameStatus.finished:
                  statusText = model.winner.isEmpty
                      ? "It's a draw!"
                      : (model.winner == GameData.myID
                            ? "You won!"
                            : "You lost!");
                  break;
              }

              return Column(
                children: [
                  // Show Room ID only for online games
                  if (!isOffline)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: model.gameId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Room ID copied to clipboard'),
                            backgroundColor: Colors.black87,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151F2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10CFFF),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.copy,
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Room ID: ${model.gameId}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Game status
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

                  // Show Start Game only when needed
                  if (!isOffline &&
                      (model.gameStatus == GameStatus.joined ||
                          model.gameStatus == GameStatus.finished))
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
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
                        onPressed: () {
                          context.read<GameBloc>().add(StartGame());
                        },
                        child: const Text(
                          "Start Game",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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

    return GestureDetector(
      onTap: () {
        if (model.gameStatus == GameStatus.inProgress &&
            model.currentPlayer == GameData.myID &&
            symbol.isEmpty) {
          context.read<GameBloc>().add(MakeMove(index));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10CFFF), width: 2),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
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
