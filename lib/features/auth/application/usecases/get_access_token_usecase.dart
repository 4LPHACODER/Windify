import '../../domain/repositories/auth_repository.dart';
import '../requests/get_access_token_request.dart';

class GetAccessTokenUsecase {
  final AuthRepository repository;

  GetAccessTokenUsecase(this.repository);

  Future<String?> call(GetAccessTokenRequest request) async {
    if (request.forceRefresh) {
      await repository.refreshSession();
    }
    return await repository.getAccessToken();
  }
}
