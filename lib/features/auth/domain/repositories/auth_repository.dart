import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> signUpWithEmailAndPassword(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}
