import 'package:equatable/equatable.dart';

// Base ProfileState class
abstract class ProfileState extends Equatable {
  final bool isLoading;
  final String? userName;
  final int? avatarIndex;
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final double overallWinRate;
  final double lastTenWinRate;
  final int rating;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.userName,
    this.avatarIndex,
    this.totalMatches = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.overallWinRate = 0.0,
    this.lastTenWinRate = 0.0,
    this.rating = 0,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    isLoading,
    userName,
    avatarIndex,
    totalMatches,
    totalWins,
    totalLosses,
    overallWinRate,
    lastTenWinRate,
    rating,
    errorMessage,
  ];
}

// Concrete profile states

class ProfileInitial extends ProfileState {
  const ProfileInitial() : super(isLoading: true);
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required String userName,
    required int avatarIndex,
    required int totalMatches,
    required int totalWins,
    required int totalLosses,
    required double overallWinRate,
    required double lastTenWinRate,
    required int rating,
  }) : super(
         isLoading: false,
         userName: userName,
         avatarIndex: avatarIndex,
         totalMatches: totalMatches,
         totalWins: totalWins,
         totalLosses: totalLosses,
         overallWinRate: overallWinRate,
         lastTenWinRate: lastTenWinRate,
         rating: rating,
       );
}

class ProfileError extends ProfileState {
  const ProfileError(String message)
    : super(isLoading: false, errorMessage: message);
}
