import 'package:tic_tac_toe/model/game/game_model.dart';

abstract class OfflineAIGameState {}

class OfflineAIGameInitial extends OfflineAIGameState {}

class OfflineAIGameInProgress extends OfflineAIGameState {
  final GameModel gameModel;
  OfflineAIGameInProgress(this.gameModel);
}

class OfflineAIGameFinished extends OfflineAIGameState {
  final GameModel gameModel;
  final String resultMessage; // "You win", "AI wins", "Draw"
  OfflineAIGameFinished(this.gameModel, this.resultMessage);
}

class OfflineAIGameFailure extends OfflineAIGameState {
  final String message;
  OfflineAIGameFailure(this.message);
}
