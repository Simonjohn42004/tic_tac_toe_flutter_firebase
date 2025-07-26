import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:tic_tac_toe/bloc/game/online/game_event.dart';
import 'package:tic_tac_toe/bloc/game/online/game_state.dart';
import 'package:tic_tac_toe/model/game/game_data.dart';
import 'package:tic_tac_toe/model/game/game_data_firestore.dart';
import 'package:tic_tac_toe/model/game/game_model.dart';
import 'package:tic_tac_toe/provider/game/game_provider.dart';
import 'package:tic_tac_toe/provider/game/offline_game_provider.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameProvider provider;
  StreamSubscription<GameModel?>? _gameModelSubscription;

  GameBloc({required this.provider}) : super(const GameState()) {
    on<CreateGame>(_onCreateGame);
    on<JoinGame>(_onJoinGame);
    on<StartGame>(_onStartGame);
    on<MakeMove>(_onMakeMove);
    on<GameModelUpdated>(_onGameModelUpdated);
  }

  Future<void> _onCreateGame(CreateGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(isLoading: true));

    await provider.createGame(myId: "X");
    GameData.myID = "X";

    _subscribeToGameUpdates();

    // 🧠 Offline mode: automatically start the game
    if (provider is OfflineGameProvider) {
      print("🧠 Offline mode detected. Starting game automatically...");
      await provider.startGame();
    }

    emit(state.copyWith(statusMessage: "Game created", isLoading: false));
    print("🟢 Created game as X. Subscribed to updates.");
  }

  Future<void> _onJoinGame(JoinGame event, Emitter<GameState> emit) async {
    emit(state.copyWith(isLoading: true));

    // 🔄 If offline, skip Firestore check and assume both players exist
    if (provider is OfflineGameProvider) {
      GameData.myID = "O";
      await provider.joinGame(gameId: event.gameId, myId: "O");
      _subscribeToGameUpdates();

      emit(
        state.copyWith(
          statusMessage: "Joined offline game as O",
          isLoading: false,
        ),
      );
      print("🟢 Joined offline game as O. Subscribed to updates.");
      return;
    }

    // 🔒 Online logic (unchanged)
    final gameModel = await GameDataFirestore.fetchGameModel(event.gameId);
    print("📦 Fetched GameModel: $gameModel");
    if (gameModel == null) {
      emit(state.copyWith(statusMessage: "Game not found", isLoading: false));
      print("❌ Failed to fetch game details: ${event.gameId}");
      return;
    }

    String joiningSymbol;
    if (gameModel.playerX.isEmpty) {
      joiningSymbol = "X";
    } else if (gameModel.playerO.isEmpty) {
      joiningSymbol = "O";
    } else {
      emit(
        state.copyWith(statusMessage: "Game is already full", isLoading: false),
      );
      print("⚠️ Game already has both players.");
      return;
    }

    final success = await provider.joinGame(
      gameId: event.gameId,
      myId: joiningSymbol,
    );

    if (success) {
      GameData.myID = joiningSymbol;
      _subscribeToGameUpdates();
      emit(
        state.copyWith(
          statusMessage: "Joined game as $joiningSymbol",
          isLoading: false,
        ),
      );
      print("🟢 Joined game as $joiningSymbol. Subscribed to updates.");
    } else {
      emit(
        state.copyWith(statusMessage: "Failed to join game", isLoading: false),
      );
      print("❌ Could not join game: ${event.gameId}");
    }
  }

  Future<void> _onStartGame(StartGame event, Emitter<GameState> emit) async {
    print("⏳ Attempting to start game...");
    await provider.startGame();
    print("✅ StartGame event sent to provider.");
  }

  Future<void> _onMakeMove(MakeMove event, Emitter<GameState> emit) async {
    print("🎯 Trying to make move at index ${event.cellIndex}");
    await provider.makeMove(event.cellIndex);
  }

  Future<void> _onGameModelUpdated(
    GameModelUpdated event,
    Emitter<GameState> emit,
  ) async {
    final model = event.model;
    emit(state.copyWith(gameModel: model));

    print("📥 GameModel updated:");
    print("   ➤ Player X    : ${model.playerX}");
    print("   ➤ Player O    : ${model.playerO}");
    print("   ➤ Current Turn: ${model.currentPlayer}");
    print("   ➤ You Are     : ${provider.myId}");
    print("   ➤ Game Status : ${model.gameStatus}");
  }

  void _subscribeToGameUpdates() {
    _gameModelSubscription?.cancel();
    _gameModelSubscription = provider.gameModelStream.listen((model) {
      print("📥 New model from provider stream: $model");
      if (model != null) add(GameModelUpdated(model));
    });
    print("🔁 Subscribed to game model stream.");
  }

  @override
  Future<void> close() {
    _gameModelSubscription?.cancel();
    provider.dispose();
    return super.close();
  }
}

// Helper for random game ID
String generateRandomId() {
  final random = Random();
  final id = 1000 + random.nextInt(9000);
  return id.toString();
}
