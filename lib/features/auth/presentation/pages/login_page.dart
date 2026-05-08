import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windify_v2/core/widgets/app_brand_logo.dart';

import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/email_input_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_input_field.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final isValid = _formKey.currentState!.validate();
    // #region agent log
    _debugLog(
      runId: 'run-pre-fix',
      hypothesisId: 'H4',
      location: 'login_page.dart:_signIn',
      message: 'SignIn validation result',
      data: {'isValid': isValid},
    );
    // #endregion
    if (!isValid) return;
    final controller = ref.read(authControllerProvider.notifier);
    await controller.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future<void> _signInWithGoogle() async {
    final controller = ref.read(authControllerProvider.notifier);
    await controller.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState?>(authControllerProvider, (previous, next) {
      if (next == null) return;
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE3F2FD), Color(0xFFF0F4F8), Colors.white],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E88E5).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D47A1).withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildLogo(),
                    const SizedBox(height: 50),
                    _buildAuthCard(context, authState),
                    const SizedBox(height: 24),
                    _buildSignUpLink(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 360;

    return AppBrandLogo(
      logoSize: compact ? 84 : 104,
      borderRadius: compact ? 22 : 26,
      subtitle: 'Weather & Forecast',
      spacing: compact ? 12 : 16,
    );
  }

  Widget _buildAuthCard(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access weather forecasts',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          EmailInputField(controller: _emailController),
          const SizedBox(height: 16),
          PasswordInputField(controller: _passwordController),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Sign In',
            onPressed: authState.isLoading ? null : _signIn,
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade200),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: Colors.grey.shade200),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GoogleSignInButton(
            onPressed: authState.isLoading ? null : _signInWithGoogle,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () {
            // #region agent log
            _debugLog(
              runId: 'run-post-fix',
              hypothesisId: 'H2',
              location: 'login_page.dart:_buildSignUpLink:onTap',
              message: 'SignUp tap invoked',
              data: {
                'emailLength': _emailController.text.trim().length,
                'passwordLength': _passwordController.text.trim().length,
              },
            );
            // #endregion
            // #region agent log
            _debugLog(
              runId: 'run-post-fix',
              hypothesisId: 'H3',
              location: 'login_page.dart:_buildSignUpLink:onTap',
              message: 'Attempting Navigator.push to SignupPage',
              data: const {
                'route': 'SignupPage',
                'validationGateRemoved': true,
              },
            );
            // #endregion
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupPage()),
            );
          },
          child: Text(
            'Sign Up',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _debugLog({
    required String runId,
    required String hypothesisId,
    required String location,
    required String message,
    required Map<String, Object?> data,
  }) async {
    final payload = <String, Object?>{
      'sessionId': '741a77',
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    // #region agent log
    debugPrint('AGENT_DEBUG_741a77 ${payload.toString()}');
    // #endregion
    try {
      await Dio().post(
        'http://127.0.0.1:7881/ingest/dd55a01c-8673-4314-ab47-4b7bcf85eab6',
        data: payload,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': '741a77',
          },
        ),
      );
    } catch (_) {}
  }
}
