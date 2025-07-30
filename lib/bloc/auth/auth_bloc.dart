import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'package:tic_tac_toe/bloc/auth/auth_event.dart';
import 'package:tic_tac_toe/bloc/auth/auth_state.dart';
import 'package:tic_tac_toe/model/profile/profile_data.dart';
import 'package:tic_tac_toe/model/profile/profile_stats.dart';
import 'package:tic_tac_toe/provider/auth/auth_provider.dart';
import 'package:tic_tac_toe/provider/profile/profile_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthenticationProvider provider, ProfileProvider profileProvider)
    : super(const AuthStateUninitialized(isLoading: true)) {
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(AuthStateRegistering(exception: null, isLoading: false));
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        devtools.log("Register failure");
        final userName = await profileProvider
            .generateAndReserveUniqueUsername();
        final newProfile = ProfileData(
          userName: userName,
          avatarIndex: 0,
          stats: ProfileStats(
            totalMatches: 0,
            totalWins: 0,
            totalLosses: 0,
            overallWinRate: 0,
            lastTenWinRate: 0,
            rating: 0,
          ),
        );
        profileProvider.saveUserProfile(
          userId: userName,
          newProfile: newProfile,
        );
        provider.sendEmailVerification();
        emit(AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        devtools.log(e.toString());
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(isLoading: true));
      try {
        await provider.sendPasswordResetEmail(email: event.email);
        emit(
          const AuthStateForgotPassword(isLoading: false, hasSentEmail: true),
        );
      } on Exception catch (e) {
        emit(AuthStateForgotPassword(isLoading: false, exception: e));
      }
    });

    // reload user event
    on<AuthEventReload>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        emit(AuthStateLoggedIn(user: provider.user!, isLoading: false));
      } else {
        emit(AuthStateNeedsVerification(isLoading: false));
      }
    });

    // initialise event
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialise();
      final user = provider.user;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // login event
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: "Please Wait while we log you in...",
        ),
      );
      final String email = event.email;
      final String password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);
        if (user.isEmailVerified) {
          emit(AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateNeedsVerification(isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
