import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_event.dart';
import 'package:tic_tac_toe/bloc/game/ai/offline_ai_state.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/provider/game/offline_ai_provider.dart';

class OfflineAIGameBloc extends Bloc<OfflineAIGameEvent, OfflineAIGameState> {
  final OfflineAIProvider _provider;

  OfflineAIGameBloc(this._provider) : super(OfflineAIGameInitial()) {
    on<StartAIGame>(_onStart);
    on<MakeAIMove>(_onHumanMove);
    on<ResetAIGame>(_onReset);
  }

  Future<void> _onStart(
    StartAIGame event,
    Emitter<OfflineAIGameState> emit,
  ) async {
    await _provider.createGame(myId: _provider.humanSymbol);
    await _provider.startGame();
    final model = _provider.currentGameModel;
    if (model != null) {
      emit(OfflineAIGameInProgress(model));
      _checkIfFinished(model, emit);
    } else {
      emit(OfflineAIGameFailure("Failed to start AI game."));
    }
  }

  Future<void> _onHumanMove(
    MakeAIMove event,
    Emitter<OfflineAIGameState> emit,
  ) async {
    await _provider.makeMove(event.index);
    final model = _provider.currentGameModel;
    if (model != null) {
      _checkIfFinished(model, emit);
      // Only emit progress if game not finished (otherwise finished state already emitted)
      if (model.gameStatus.toString() == "GameStatus.inProgress") {
        emit(OfflineAIGameInProgress(model));
      }
    } else {
      emit(OfflineAIGameFailure("Error making move"));
    }
  }

  Future<void> _onReset(
    ResetAIGame event,
    Emitter<OfflineAIGameState> emit,
  ) async {
    await _provider.startGame();
    final model = _provider.currentGameModel;
    if (model != null) {
      emit(OfflineAIGameInProgress(model));
    } else {
      emit(OfflineAIGameFailure("Failed to reset AI game."));
    }
  }

  void _checkIfFinished(GameModel model, Emitter<OfflineAIGameState> emit) {
    if (model.gameStatus.toString() == "GameStatus.finished") {
      String result;
      if (model.winner == _provider.humanSymbol) {
        result = "You Win!";
      } else if (model.winner == _provider.aiSymbol) {
        result = "AI Wins!";
      } else {
        result = "It's a Draw!";
      }
      emit(OfflineAIGameFinished(model, result));
    }
  }

  @override
  Future<void> close() {
    _provider.dispose();
    return super.close();
  }
}
