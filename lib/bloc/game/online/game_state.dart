// game_state.dart
import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';

class GameState extends Equatable {
  final GameModel? gameModel;
  final String statusMessage;
  final bool isLoading;

  const GameState({
    this.gameModel,
    this.statusMessage = "Waiting...",
    this.isLoading = false,
  });

  GameState copyWith({
    GameModel? gameModel,
    String? statusMessage,
    bool? isLoading,
  }) {
    return GameState(
      gameModel: gameModel ?? this.gameModel,
      statusMessage: statusMessage ?? this.statusMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [gameModel, statusMessage, isLoading];
}
