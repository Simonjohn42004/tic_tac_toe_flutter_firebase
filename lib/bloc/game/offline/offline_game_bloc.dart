import 'package:flutter_bloc/flutter_bloc.dart';
import 'offline_game_event.dart';
import 'offline_game_state.dart';
import 'package:tic_tac_toe/provider/game/offline_game_provider.dart';

class OfflineGameBloc extends Bloc<OfflineGameEvent, OfflineGameState> {
  final OfflineGameProvider _provider;

  OfflineGameBloc(this._provider) : super(OfflineGameInitial()) {
    on<StartOfflineGame>(_onStartGame);
    on<MakeOfflineMove>(_onMakeMove);
    on<ResetOfflineGame>(_onResetGame);
  }

  Future<void> _onStartGame(
    StartOfflineGame event,
    Emitter<OfflineGameState> emit,
  ) async {
    await _provider.createGame(myId: "X");
    await _provider.startGame();
    final model = _provider.currentGameModel;
    if (model != null) {
      emit(OfflineGameInProgress(model));
    } else {
      emit(OfflineGameFailure("Failed to start the game."));
    }
  }

  Future<void> _onMakeMove(
    MakeOfflineMove event,
    Emitter<OfflineGameState> emit,
  ) async {
    await _provider.makeMove(event.index);
    final model = _provider.currentGameModel;
    if (model != null) {
      emit(OfflineGameInProgress(model));
    } else {
      emit(OfflineGameFailure("Failed to make the move."));
    }
  }

  Future<void> _onResetGame(
    ResetOfflineGame event,
    Emitter<OfflineGameState> emit,
  ) async {
    await _provider.startGame();
    final model = _provider.currentGameModel;
    if (model != null) {
      emit(OfflineGameInProgress(model));
    } else {
      emit(OfflineGameFailure("Failed to reset the game."));
    }
  }

  @override
  Future<void> close() {
    _provider.dispose();
    return super.close();
  }
}
