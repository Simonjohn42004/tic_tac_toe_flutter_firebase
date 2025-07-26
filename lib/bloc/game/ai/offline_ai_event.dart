abstract class OfflineAIGameEvent {}

class StartAIGame extends OfflineAIGameEvent {}

class MakeAIMove extends OfflineAIGameEvent {
  final int index; // Human move index
  MakeAIMove(this.index);
}

class ResetAIGame extends OfflineAIGameEvent {}
