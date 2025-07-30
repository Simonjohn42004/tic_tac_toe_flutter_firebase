import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:tic_tac_toe/model/profile/profile_data.dart';
import 'package:tic_tac_toe/model/profile/profile_stats.dart';
import 'package:tic_tac_toe/provider/profile/profile_provider.dart';

class FirebaseRealtimeProfileProvider implements ProfileProvider {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Future<ProfileData> fetchUserProfile(String userId) async {
    final snapshot = await _database.child('profiles').child(userId).get();
    if (!snapshot.exists) {
      // Return a default blank profile if none exists yet.
      return ProfileData(
        userName: '',
        avatarIndex: 0,
        stats: ProfileStats(
          totalMatches: 0,
          totalWins: 0,
          totalLosses: 0,
          overallWinRate: 0.0,
          lastTenWinRate: 0.0,
          rating: 0,
        ),
      );
    }
    return ProfileData.fromJson(snapshot.value as Map<dynamic, dynamic>);
  }

  @override
  Future<void> updateUserName({
    required String userId,
    required String newUserName,
  }) async {
    // Optionally: You can also add a uniqueness check here to double-check on updates
    await _database.child('profiles').child(userId).update({
      'userName': newUserName,
    });
  }

  @override
  Future<void> updateAvatar({
    required String userId,
    required int avatarIndex,
  }) async {
    await _database.child('profiles').child(userId).update({
      'avatarIndex': avatarIndex,
    });
  }

  @override
  Future<ProfileStats> refreshUserStats(String userId) async {
    final snapshot = await _database
        .child('profiles')
        .child(userId)
        .child('stats')
        .get();
    if (!snapshot.exists) {
      return ProfileStats(
        totalMatches: 0,
        totalWins: 0,
        totalLosses: 0,
        overallWinRate: 0.0,
        lastTenWinRate: 0.0,
        rating: 0,
      );
    }
    return ProfileStats.fromJson(snapshot.value as Map<dynamic, dynamic>);
  }

  @override
  Future<void> resetProfile(String userId) async {
    await _database.child('profiles').child(userId).remove();
  }

  @override
  Future<String> generateAndReserveUniqueUsername() async {
    const maxAttempts = 10;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final candidate = _generateRandomUsername();

      final snapshot = await _database
          .child('profiles')
          .orderByChild('userName')
          .equalTo(candidate)
          .get();

      if (!snapshot.exists) {
        // Username is unique, can be reserved (final reservation happens at profile creation)
        return candidate;
      }
      // else try again ...
    }

    throw Exception(
      'Failed to generate a unique username after $maxAttempts attempts.',
    );
  }

  String _generateRandomUsername() {
    final random = Random.secure();
    final suffix =
        random.nextInt(9000) + 1000; // Random number between 1000-9999
    return 'Player$suffix';
  }

  @override
  Future<void> saveUserProfile({
    required String userId,
    required ProfileData newProfile,
  }) async {
    final DatabaseReference ref = _database.child("profiles").child(userId);
    await ref.set(newProfile.toJson());
  }
}
