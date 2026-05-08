import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/sign_in_with_google_request.dart';

class SignInWithGoogleUsecase {
  final AuthRepository repository;

  SignInWithGoogleUsecase(this.repository);

  Future<AppUser> call(SignInWithGoogleRequest request) async {
    return await repository.signInWithGoogle();
  }
}
