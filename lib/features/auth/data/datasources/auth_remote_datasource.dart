import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session_info.dart';

abstract class AuthRemoteDatasource {
  Future<AppUser?> getCurrentUser();
  Future<AuthSessionInfo?> getCurrentSession();
  Future<String?> getAccessToken();
  Future<AuthSessionInfo?> refreshSession();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> signUpWithEmailAndPassword(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}
