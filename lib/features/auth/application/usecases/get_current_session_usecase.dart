import '../../domain/entities/auth_session_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/get_current_session_request.dart';

class GetCurrentSessionUsecase {
  final AuthRepository repository;

  GetCurrentSessionUsecase(this.repository);

  Future<AuthSessionInfo?> call(GetCurrentSessionRequest request) async {
    if (request.forceRefresh) {
      return await repository.refreshSession();
    }
    return await repository.getCurrentSession();
  }
}
