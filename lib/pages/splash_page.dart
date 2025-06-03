import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> _checkLogin(BuildContext context) async {
    final token = await UserService.getToken();
    if (token != null) {
      final user = await UserService().getCurrentUser(token);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLogin(context));
    return const Scaffold(
      backgroundColor: Color(0xFFF6F8FB),
      body: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 7,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
