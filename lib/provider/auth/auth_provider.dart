
import 'package:tic_tac_toe/model/auth/auth_user.dart';

abstract class AuthenticationProvider {
  AuthUser? get user;
  Future<AuthUser> logIn({required String email, required String password});
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> initialise();
}
