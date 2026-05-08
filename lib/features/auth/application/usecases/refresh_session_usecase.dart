import '../../domain/entities/auth_session_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../requests/refresh_session_request.dart';

class RefreshSessionUsecase {
  final AuthRepository repository;

  RefreshSessionUsecase(this.repository);

  Future<AuthSessionInfo?> call(RefreshSessionRequest request) async {
    return await repository.refreshSession();
  }
}
