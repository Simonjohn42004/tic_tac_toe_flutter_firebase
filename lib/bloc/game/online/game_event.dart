// game_event.dart
import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe/model/game_model.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateGame extends GameEvent {
  final bool offline;
  CreateGame({required this.offline});
}

class JoinGame extends GameEvent {
  final String gameId;
  JoinGame(this.gameId);
}

class StartGame extends GameEvent {}

class MakeMove extends GameEvent {
  final int cellIndex;
  MakeMove(this.cellIndex);
}

class GameModelUpdated extends GameEvent {
  final GameModel model;
  GameModelUpdated(this.model);
}
