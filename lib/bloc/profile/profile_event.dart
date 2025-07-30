import 'package:equatable/equatable.dart';

// Base class for all Profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Triggers when the profile screen is opened or data needs to be (re)loaded
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

// Triggers when the user wants to update their display name
class UpdateUserName extends ProfileEvent {
  final String newUserName;
  const UpdateUserName(this.newUserName);

  @override
  List<Object?> get props => [newUserName];
}

// Triggers when the user selects a new avatar image
class UpdateAvatar extends ProfileEvent {
  final int newAvatarIndex;
  const UpdateAvatar(this.newAvatarIndex);

  @override
  List<Object?> get props => [newAvatarIndex];
}

// Triggers if you need to refresh the stats (e.g., after a completed match)
class RefreshProfileStats extends ProfileEvent {
  const RefreshProfileStats();
}

// Optional: for error handling or manual profile data reloads
class ProfileErrorOccurred extends ProfileEvent {
  final String message;
  const ProfileErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
