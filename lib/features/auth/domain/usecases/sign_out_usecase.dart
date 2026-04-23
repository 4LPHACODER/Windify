import '../repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository repository;

  SignOutUsecase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}
