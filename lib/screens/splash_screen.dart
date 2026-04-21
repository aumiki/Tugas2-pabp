import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Give AuthProvider time to load from storage
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    // Wait if still loading
    while (auth.status == AuthStatus.initial ||
        auth.status == AuthStatus.loading) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => auth.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond_outlined,
                color: AppColors.secondary, size: 56),
            const SizedBox(height: 20),
            Text(
              'MAISONLUXE',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 6,
                    fontSize: 26,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'LUXURY REDEFINED',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 4,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.secondary,
                strokeWidth: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
