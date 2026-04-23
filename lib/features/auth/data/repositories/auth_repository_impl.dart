import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_remote_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
    : datasource = datasource ?? AuthRemoteDatasourceImpl();

  @override
  Future<AppUser?> getCurrentUser() async {
    return await datasource.getCurrentUser();
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await datasource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await datasource.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    return await datasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await datasource.signOut();
  }
}
