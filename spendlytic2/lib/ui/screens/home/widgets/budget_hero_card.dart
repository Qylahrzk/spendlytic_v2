import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';

class BudgetHeroCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const BudgetHeroCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;
    final progress = totalBudget == 0
        ? 0.0
        : (totalSpent / totalBudget).clamp(0.0, 1.0);
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Modern Dark Gradient (Purple -> Dark Blue)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A1B9A), // Deep Purple
            Color(0xFF283593), // Dark Indigo
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Budget Hero", style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          const Text("Remaining:", style: TextStyle(color: Colors.white70)),
          Text(currency.format(remaining), style: AppTextStyles.cardValue),
          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining < 0 ? AppColors.error : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("Spent", totalSpent, currency),
              _buildMiniStat("Budget", totalBudget, currency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(
          fmt.format(value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
