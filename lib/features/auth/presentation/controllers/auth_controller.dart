import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/auth_providers.dart';
import '../../application/requests/get_access_token_request.dart';
import '../../application/requests/get_current_user_request.dart';
import '../../application/requests/get_current_session_request.dart';
import '../../application/requests/refresh_session_request.dart';
import '../../application/requests/sign_in_request.dart';
import '../../application/requests/sign_in_with_google_request.dart';
import '../../application/requests/sign_out_request.dart';
import '../../application/requests/sign_up_request.dart';
import '../../application/services/auth_flow_service.dart';
import '../../domain/entities/auth_session_info.dart';
import '../states/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthFlowService _authFlowService;

  AuthController._(this._authFlowService) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authFlowService.getCurrentUser(
        const GetCurrentUserRequest(),
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authFlowService.signIn(
        SignInRequest(email: email, password: password),
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authFlowService.signUp(
        SignUpRequest(email: email, password: password),
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authFlowService.signInWithGoogle(
        const SignInWithGoogleRequest(),
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authFlowService.signOut(const SignOutRequest());
      state = state.copyWith(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Debug/testing helper for manual Postman workflows.
  /// Do not auto-display this token in normal UI flows.
  Future<String?> getAccessTokenForDebug({bool forceRefresh = false}) async {
    return await _authFlowService.getAccessToken(
      GetAccessTokenRequest(forceRefresh: forceRefresh),
    );
  }

  /// Returns session metadata for diagnostics without altering login UI behavior.
  Future<AuthSessionInfo?> getCurrentSessionForDebug({
    bool forceRefresh = false,
  }) async {
    return await _authFlowService.getCurrentSession(
      GetCurrentSessionRequest(forceRefresh: forceRefresh),
    );
  }

  Future<AuthSessionInfo?> refreshSessionForDebug() async {
    return await _authFlowService.refreshSession(const RefreshSessionRequest());
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authFlowService = ref.watch(authFlowServiceProvider);
    return AuthController._(authFlowService);
  },
);
