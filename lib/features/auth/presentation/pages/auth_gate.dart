import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../weather_map/presentation/pages/weather_map_page.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.user != null) {
      return const WeatherMapPage();
    } else {
      return const LoginPage();
    }
  }
}
