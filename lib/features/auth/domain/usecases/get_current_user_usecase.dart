import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<AppUser?> call() async {
    return await repository.getCurrentUser();
  }
}
