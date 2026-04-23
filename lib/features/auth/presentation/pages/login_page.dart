import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (!_formKey.currentState!.validate()) return;
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
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.waves, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Windify',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Weather & Forecast',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
        ),
      ],
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
            if (!_formKey.currentState!.validate()) return;
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
}
