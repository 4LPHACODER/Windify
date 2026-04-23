import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  final AuthRepository repository;

  SignInWithGoogleUsecase(this.repository);

  Future<AppUser> call() async {
    return await repository.signInWithGoogle();
  }
}
