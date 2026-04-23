import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../providers/auth_providers.dart';
import '../states/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final SignInUsecase _signInUsecase;
  final SignUpUsecase _signUpUsecase;
  final SignInWithGoogleUsecase _signInWithGoogleUsecase;
  final SignOutUsecase _signOutUsecase;
  final GetCurrentUserUsecase _getCurrentUserUsecase;

  AuthController._(
    this._signInUsecase,
    this._signUpUsecase,
    this._signInWithGoogleUsecase,
    this._signOutUsecase,
    this._getCurrentUserUsecase,
  ) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _getCurrentUserUsecase();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signInUsecase(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signUpUsecase(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signInWithGoogleUsecase();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _signOutUsecase();
      state = state.copyWith(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final signInUsecase = ref.watch(signInUsecaseProvider);
    final signUpUsecase = ref.watch(signUpUsecaseProvider);
    final signInWithGoogleUsecase = ref.watch(signInWithGoogleUsecaseProvider);
    final signOutUsecase = ref.watch(signOutUsecaseProvider);
    final getCurrentUserUsecase = ref.watch(getCurrentUserUsecaseProvider);

    return AuthController._(
      signInUsecase,
      signUpUsecase,
      signInWithGoogleUsecase,
      signOutUsecase,
      getCurrentUserUsecase,
    );
  },
);
