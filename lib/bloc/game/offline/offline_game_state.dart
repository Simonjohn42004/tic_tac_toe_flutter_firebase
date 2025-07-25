import 'package:tic_tac_toe/model/game_model.dart';

abstract class OfflineGameState {}

class OfflineGameInitial extends OfflineGameState {}

class OfflineGameInProgress extends OfflineGameState {
  final GameModel gameModel;

  OfflineGameInProgress(this.gameModel);
}

class OfflineGameFailure extends OfflineGameState {
  final String message;

  OfflineGameFailure(this.message);
}
