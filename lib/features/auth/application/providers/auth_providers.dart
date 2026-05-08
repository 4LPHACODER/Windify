import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_flow_service.dart';
import '../usecases/get_access_token_usecase.dart';
import '../usecases/get_current_user_usecase.dart';
import '../usecases/get_current_session_usecase.dart';
import '../usecases/refresh_session_usecase.dart';
import '../usecases/sign_in_usecase.dart';
import '../usecases/sign_in_with_google_usecase.dart';
import '../usecases/sign_out_usecase.dart';
import '../usecases/sign_up_usecase.dart';

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

final signInWithGoogleUsecaseProvider = Provider<SignInWithGoogleUsecase>((ref) {
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

final getCurrentSessionUsecaseProvider = Provider<GetCurrentSessionUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentSessionUsecase(repository);
});

final getAccessTokenUsecaseProvider = Provider<GetAccessTokenUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetAccessTokenUsecase(repository);
});

final refreshSessionUsecaseProvider = Provider<RefreshSessionUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshSessionUsecase(repository);
});

// Service provider
final authFlowServiceProvider = Provider<AuthFlowService>((ref) {
  final signInUsecase = ref.watch(signInUsecaseProvider);
  final signUpUsecase = ref.watch(signUpUsecaseProvider);
  final signInWithGoogleUsecase = ref.watch(signInWithGoogleUsecaseProvider);
  final signOutUsecase = ref.watch(signOutUsecaseProvider);
  final getCurrentUserUsecase = ref.watch(getCurrentUserUsecaseProvider);
  final getCurrentSessionUsecase = ref.watch(getCurrentSessionUsecaseProvider);
  final getAccessTokenUsecase = ref.watch(getAccessTokenUsecaseProvider);
  final refreshSessionUsecase = ref.watch(refreshSessionUsecaseProvider);
  return AuthFlowService(
    signInUsecase,
    signUpUsecase,
    signInWithGoogleUsecase,
    signOutUsecase,
    getCurrentUserUsecase,
    getCurrentSessionUsecase,
    getAccessTokenUsecase,
    refreshSessionUsecase,
  );
});
