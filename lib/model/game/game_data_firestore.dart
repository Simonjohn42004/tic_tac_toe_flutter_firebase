import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import 'game_model.dart';

class GameDataFirestore {
  static final Logger log = Logger();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save GameModel to Firestore with error handling
  static Future<void> saveGameModel(GameModel model) async {
    log.i('Attempting to save game model: ${model.toMap()}');
    if (model.gameId == "-1") {
      log.w('Game ID is -1; skipping Firestore save.');
      return;
    }
    try {
      await _firestore.collection('games').doc(model.gameId).set(model.toMap());
      log.i('GameModel saved successfully for Game ID: ${model.gameId}');
    } on FirebaseException catch (e) {
      log.e(
        'FirebaseException while saving GameModel: ${e.code}: ${e.message}',
      );
      rethrow; // Or handle as per your UX (e.g., show a dialog)
    } catch (e) {
      log.e('Unexpected error while saving GameModel: $e');
      rethrow;
    }
  }

  /// Listen for real-time updates to a GameModel document.
  static Stream<GameModel?> listenGameModel(String gameId) {
    if (gameId == "-1") {
      log.w('Tried to listen to Game ID -1; returning empty stream');
      return const Stream.empty();
    }
    log.i('Setting up listener for Game ID: $gameId');
    return _firestore.collection('games').doc(gameId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        log.f('GameModel snapshot received for $gameId.');
        try {
          return GameModel.fromMap(snapshot.data()!);
        } catch (e) {
          log.e('Error parsing GameModel from snapshot: $e');
          return null;
        }
      } else {
        log.w('No document found for Game ID: $gameId');
        return null;
      }
    });
  }

  /// Fetch a GameModel once (not real-time).
  static Future<GameModel?> fetchGameModel(String gameId) async {
    if (gameId == "-1") {
      log.e('Game ID is -1; fetch will not be performed.');
      return null;
    }
    log.i('Fetching GameModel for Game ID: $gameId');
    try {
      final doc = await _firestore.collection('games').doc(gameId).get();
      if (doc.exists && doc.data() != null) {
        return GameModel.fromMap(doc.data()!);
      } else {
        log.w('No GameModel found for Game ID: $gameId');
        return null;
      }
    } on FirebaseException catch (e) {
      log.e(
        'FirebaseException while fetching GameModel: ${e.code}: ${e.message}',
      );
      return null;
    } catch (e) {
      log.e('Unexpected error while fetching GameModel: $e');
      return null;
    }
  }

  /// Delete a game room by its gameId.
  static Future<void> deleteGameModel(String gameId) async {
    log.i('Attempting to delete game for Game ID: $gameId');
    if (gameId == "-1") {
      log.w('Game ID is -1; skipping Firestore delete.');
      return;
    }
    try {
      await _firestore.collection('games').doc(gameId).delete();
      log.i('GameModel deleted successfully for Game ID: $gameId');
    } on FirebaseException catch (e) {
      log.e(
        'FirebaseException while deleting GameModel: ${e.code}: ${e.message}',
      );
      rethrow; // Or handle as per your UX (e.g., show a dialog)
    } catch (e) {
      log.e('Unexpected error while deleting GameModel: $e');
      rethrow;
    }
  }
}
