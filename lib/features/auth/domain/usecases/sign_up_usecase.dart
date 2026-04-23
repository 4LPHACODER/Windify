import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  Future<AppUser> call(String email, String password) async {
    return await repository.signUpWithEmailAndPassword(email, password);
  }
}
