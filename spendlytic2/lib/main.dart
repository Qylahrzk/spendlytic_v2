import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repositories
import 'package:spendlytic/data/repositories/profile_repository.dart';
import 'package:spendlytic/data/repositories/auth_repository.dart';
import 'package:spendlytic/data/repositories/transaction_repository.dart';

// Cubits
import 'package:spendlytic/logic/budget_cubit/budget_cubit.dart';
import 'package:spendlytic/logic/profile_cubit/profile_cubit.dart';
import 'package:spendlytic/logic/auth_cubit/auth_cubit.dart';
import 'package:spendlytic/logic/auth_cubit/auth_state.dart';
import 'package:spendlytic/logic/transaction_cubit/transaction_cubit.dart';

// Services
import 'services/biometric_service.dart';

// Core
import 'core/app_theme.dart';

// Screens
import 'package:spendlytic/ui/screens/biometric_check_screen.dart';
import 'ui/screens/login/login_screen.dart';
import 'ui/global_widgets/app_navigation_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Env
  await dotenv.load(fileName: ".env");

  // Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const SpendlyticRescueApp());
}

class SpendlyticRescueApp extends StatelessWidget {
  const SpendlyticRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => TransactionRepository()),
        RepositoryProvider(create: (_) => ProfileRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // ✅ FIX: Added BiometricService() as the second argument
          BlocProvider<AuthenticationCubit>(
            create: (context) => AuthenticationCubit(
              context.read<AuthRepository>(),
              BiometricService(),
            ),
          ),
          BlocProvider<TransactionCubit>(
            create: (context) =>
                TransactionCubit(context.read<TransactionRepository>()),
          ),
          BlocProvider<BudgetCubit>(
            create: (context) =>
                BudgetCubit(context.read<TransactionRepository>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) =>
                ProfileCubit(context.read<ProfileRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Spendlytic',
          debugShowCheckedModeBanner: false,

          // ✅ Use the Theme from Core
          theme: AppTheme.light,

          // ✅ Auth Gatekeeper
          home: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthenticationAuthenticated) {
                // ✅ Check if we need to show the Face ID Lock Screen
                if (state.requiresBiometric) {
                  return const BiometricCheckScreen();
                } else {
                  // User logged in manually or passed Face ID -> Go to App
                  return const AppNavigationLayout();
                }
              } else if (state is AuthenticationUnauthenticated) {
                return const LoginScreen();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }
}
