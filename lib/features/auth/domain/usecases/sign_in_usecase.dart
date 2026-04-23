import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository repository;

  SignInUsecase(this.repository);

  Future<AppUser> call(String email, String password) async {
    return await repository.signInWithEmailAndPassword(email, password);
  }
}
