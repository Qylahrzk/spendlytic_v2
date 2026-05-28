import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';

class BudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final IconData icon; // Added icon here for easier UI
  final VoidCallback onTap; // To open edit dialog

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');
    // Avoid division by zero
    final percent = (limit == 0) ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final isOverBudget = limit > 0 && spent > limit;
    final hasBudget = limit > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: hasBudget ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: hasBudget
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: hasBudget ? AppColors.darkPurple : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: hasBudget
                            ? AppTextStyles.h3
                            : AppTextStyles.h3.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasBudget
                            ? "${currency.format(spent)} of ${currency.format(limit)}"
                            : "No limit set",
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                ),

                // Percentage or Arrow
                if (hasBudget)
                  Text(
                    "${(percent * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isOverBudget
                          ? AppColors.error
                          : AppColors.darkIndigo,
                    ),
                  )
                else
                  const Icon(Icons.add_circle_outline, color: Colors.grey),
              ],
            ),

            if (hasBudget) ...[
              const SizedBox(height: 20),
              // Gradient Progress Bar
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 12,
                        width: constraints.maxWidth * percent,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: isOverBudget
                              ? null
                              : AppColors.mainGradient,
                          color: isOverBudget ? AppColors.error : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
