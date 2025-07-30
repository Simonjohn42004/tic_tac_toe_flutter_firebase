import 'package:tic_tac_toe/model/profile/profile_data.dart';
import 'package:tic_tac_toe/model/profile/profile_stats.dart';

/// Abstract interface for Profile data operations (e.g., for a Firebase implementation)
abstract class ProfileProvider {
  /// Loads the current user's profile from the backend (Firebase/other).
  Future<ProfileData> fetchUserProfile(String userId);

  Future<void> saveUserProfile({
    required String userId,
    required ProfileData newProfile,
  });

  /// Updates the user's display name.
  Future<void> updateUserName({
    required String userId,
    required String newUserName,
  });

  /// Updates the user's avatar index.
  Future<void> updateAvatar({required String userId, required int avatarIndex});

  /// Refreshes the user statistics (optionally called after matches).
  Future<ProfileStats> refreshUserStats(String userId);

  /// Optionally: Used to handle log out, deletion, or full profile reset.
  Future<void> resetProfile(String userId);

  /// Generates and reserves a unique username for new users during registration.
  Future<String> generateAndReserveUniqueUsername();
}
