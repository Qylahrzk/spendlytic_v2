import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../../logic/transaction_cubit/transaction_cubit.dart';
import '../../../logic/transaction_cubit/transaction_state.dart';
import '../../../logic/profile_cubit/profile_cubit.dart'; // ✅ Import ProfileCubit

// Constants
import '../../../core/app_text_styles.dart';

// Local Widgets
import 'widgets/home_header.dart';
import 'widgets/budget_hero_card.dart';
import '../../global_widgets/transaction_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ 1. Fetch Transactions
    context.read<TransactionCubit>().loadTransactions();
    // ✅ 2. Fetch User Profile (Name)
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            // Loading State
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error State
            if (state is TransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text("Something went wrong", style: AppTextStyles.body),
                    TextButton(
                      onPressed: () {
                        context.read<TransactionCubit>().loadTransactions();
                        context.read<ProfileCubit>().loadProfile();
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            // Loaded State
            if (state is TransactionLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TransactionCubit>().loadTransactions();
                  context.read<ProfileCubit>().loadProfile();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header (Self-updating)
                      const HomeHeader(),
                      const SizedBox(height: 24),

                      // 2. Budget Hero Card
                      BudgetHeroCard(
                        totalBudget: state.totalBudget,
                        totalSpent: state.totalExpenses,
                      ),
                      const SizedBox(height: 30),

                      // 3. Recent Transactions Title
                      const Text(
                        "Recent Transactions",
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),

                      // 4. List Items
                      if (state.transactions.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: const Text(
                            "No expenses yet. Add one!",
                            style: AppTextStyles.body,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionListItem(
                              transaction: state.transactions[index],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
