import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../domain/entities/app_user.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabase;
  late final GoogleSignIn _googleSignIn;

  AuthRemoteDatasourceImpl() : _supabase = Supabase.instance.client {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    final webClientId = EnvConfig.googleWebClientId;
    final androidClientId = EnvConfig.googleAndroidClientId;
    final iosClientId = EnvConfig.googleIosClientId;

    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: webClientId,
        serverClientId: webClientId,
      );
    } else {
      final String? serverClientId;
      if (defaultTargetPlatform == TargetPlatform.android) {
        serverClientId = androidClientId;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        serverClientId = iosClientId ?? androidClientId ?? webClientId;
      } else {
        serverClientId = webClientId;
      }
      _googleSignIn = GoogleSignIn(serverClientId: serverClientId);
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    return AppUser.fromSupabase(session.user.toJson());
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return AppUser.fromSupabase(response.user!.toJson());
    } on AuthException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return AppUser.fromSupabase(response.user!.toJson());
    } on AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Failed to get Google auth tokens');
      }

      developer.log('Signing in with Google ID token', name: 'Auth');
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed: no user returned');
      }

      developer.log(
        'Google sign in successful for user ${response.user!.id}',
        name: 'Auth',
      );
      return AppUser.fromSupabase(response.user!.toJson());
    } catch (e) {
      developer.log('Google sign in error: $e', name: 'Auth', error: e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      developer.log('Google sign out warning: $e', name: 'Auth');
    }
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      developer.log('Supabase sign out warning: $e', name: 'Auth');
    }
  }
}
