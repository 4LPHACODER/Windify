import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Usecase providers
final signInUsecaseProvider = Provider<SignInUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUsecase(repository);
});

final signUpUsecaseProvider = Provider<SignUpUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUsecase(repository);
});

final signInWithGoogleUsecaseProvider = Provider<SignInWithGoogleUsecase>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUsecase(repository);
});

final signOutUsecaseProvider = Provider<SignOutUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUsecase(repository);
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUsecase(repository);
});
