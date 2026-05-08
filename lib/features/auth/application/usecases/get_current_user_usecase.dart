import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/get_current_user_request.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<AppUser?> call(GetCurrentUserRequest request) async {
    if (request.forceRefresh) {
      await repository.refreshSession();
    }
    return await repository.getCurrentUser();
  }
}
