import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/sign_up_request.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  Future<AppUser> call(SignUpRequest request) async {
    return await repository.signUpWithEmailAndPassword(
      request.email,
      request.password,
    );
  }
}
