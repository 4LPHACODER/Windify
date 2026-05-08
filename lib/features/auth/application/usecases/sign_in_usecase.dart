import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/sign_in_request.dart';

class SignInUsecase {
  final AuthRepository repository;

  SignInUsecase(this.repository);

  Future<AppUser> call(SignInRequest request) async {
    return await repository.signInWithEmailAndPassword(
      request.email,
      request.password,
    );
  }
}
