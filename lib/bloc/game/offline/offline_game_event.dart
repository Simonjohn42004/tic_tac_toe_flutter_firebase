abstract class OfflineGameEvent {}

class StartOfflineGame extends OfflineGameEvent {}

class MakeOfflineMove extends OfflineGameEvent {
  final int index;

  MakeOfflineMove(this.index);
}

class ResetOfflineGame extends OfflineGameEvent {}
