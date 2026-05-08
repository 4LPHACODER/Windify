import '../../domain/repositories/auth_repository.dart';
import '../requests/sign_out_request.dart';

class SignOutUsecase {
  final AuthRepository repository;

  SignOutUsecase(this.repository);

  Future<void> call(SignOutRequest request) async {
    await repository.signOut();
  }
}
