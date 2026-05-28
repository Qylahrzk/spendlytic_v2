import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../../logic/transaction_cubit/transaction_cubit.dart';
import '../../../logic/transaction_cubit/transaction_state.dart';
import '../../../logic/budget_cubit/budget_cubit.dart';
import '../../../logic/budget_cubit/budget_state.dart';

// Data
import '../../../data/models/category_model.dart';

// Widgets
import 'widgets/budget_card.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().loadBudgets();
  }

  // Now takes the category directly!
  void _showSetBudgetDialog(CategoryModel category, double currentLimit) {
    final amountCtrl = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Required for full height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, // Key for keyboard
        ),
        child: SingleChildScrollView(
          // Allow scrolling if screen is small
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Set Budget for ${category.name}",
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true, // Focus immediately
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkPurple,
                  ),
                  decoration: InputDecoration(
                    labelText: "Monthly Limit",
                    prefixText: "RM ",
                    prefixStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.darkPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0;
                      if (amount >= 0) {
                        // This now triggers the instant UI update
                        context.read<BudgetCubit>().setBudget(
                          category.name,
                          amount,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "SAVE LIMIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Monthly Budgets"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<BudgetCubit>().loadBudgets(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // No FAB anymore! The list drives the actions.
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, txState) {
          return BlocBuilder<BudgetCubit, BudgetState>(
            builder: (context, budgetState) {
              if (budgetState is BudgetLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 1. Prepare Data Maps
              final budgetMap = <String, double>{};
              if (budgetState is BudgetLoaded) {
                for (var b in budgetState.budgets) {
                  budgetMap[b.category] = b.amount;
                }
              }

              final spentMap = <String, double>{};
              if (txState is TransactionLoaded) {
                for (var tx in txState.transactions) {
                  spentMap[tx.category] =
                      (spentMap[tx.category] ?? 0) + tx.amount;
                }
              }

              // 2. Render ALL Categories from the Model
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                // Exclude "General" if you want, or keep it.
                // Usually budgets are specific, but General is fine too.
                itemCount: CategoryModel.list.length,
                itemBuilder: (context, index) {
                  final category = CategoryModel.list[index];

                  // Lookup values
                  final limit = budgetMap[category.name] ?? 0.0;
                  final spent = spentMap[category.name] ?? 0.0;

                  return BudgetCard(
                    category: category.name,
                    icon: category.icon,
                    limit: limit,
                    spent: spent,
                    onTap: () => _showSetBudgetDialog(category, limit),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
