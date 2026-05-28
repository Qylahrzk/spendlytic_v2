import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Clear inputs when switching between Login and Register tabs
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _emailCtrl.clear();
        _passCtrl.clear();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_tabController.index == 0) {
      context.read<AuthenticationCubit>().signIn(email, pass);
    } else {
      context.read<AuthenticationCubit>().signUp(email, pass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _tabController.index == 0;
    final activeColor = isLogin ? AppColors.darkPurple : AppColors.darkIndigo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          // ✅ CRITICAL: We do NOT navigate here.
          // main.dart listens to the state and switches the screen automatically.
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        isLogin ? Icons.lock_open : Icons.person_add,
                        size: 60,
                        color: activeColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isLogin ? "Welcome Back" : "Join Spendlytic",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin
                            ? "Sign in to continue managing your budget."
                            : "Create an account to start tracking.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // --- Tabs ---
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: "LOGIN"),
                            Tab(text: "REGISTER"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Inputs ---
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),

                      // --- Submit Button ---
                      BlocBuilder<AuthenticationCubit, AuthenticationState>(
                        builder: (context, state) {
                          if (state is AuthenticationLoading) {
                            return const CircularProgressIndicator();
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: activeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isLogin ? "LOGIN" : "CREATE ACCOUNT",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // --- Biometric Button (Only in Login Mode) ---
                      if (isLogin) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: () {
                              // Connects to the AuthCubit logic we added earlier
                              context
                                  .read<AuthenticationCubit>()
                                  .loginWithBiometrics();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                size: 40,
                                color: activeColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            "Use Face ID / Touch ID",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
