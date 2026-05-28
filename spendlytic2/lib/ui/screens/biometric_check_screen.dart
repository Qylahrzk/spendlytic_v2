import 'package:flutter/material.dart';
import '../../services/biometric_service.dart';
import '../global_widgets/app_navigation_layout.dart';
import '../../core/app_colors.dart';

class BiometricCheckScreen extends StatefulWidget {
  const BiometricCheckScreen({super.key});

  @override
  State<BiometricCheckScreen> createState() => _BiometricCheckScreenState();
}

class _BiometricCheckScreenState extends State<BiometricCheckScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    setState(() => _isAuthenticating = true);

    final authenticated = await BiometricService().authenticate();

    if (authenticated && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppNavigationLayout()),
      );
    } else {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ FIX: Use darkPurple instead of primary
      backgroundColor: AppColors.darkPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Spendlytic Locked",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _checkBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: const Text("UNLOCK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  // ✅ FIX: Use darkPurple for text
                  foregroundColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            if (_isAuthenticating)
              const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
