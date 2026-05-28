import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart'; // ✅ Import CategoryModel

// Core
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_MY', symbol: 'RM ');

    // ✅ Use the centralized model to get the correct icon/color
    final categoryData = CategoryModel.fromName(transaction.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              categoryData.icon, // ✅ Dynamic Icon
              color: AppColors.darkPurple, // Consistent Theme Color
            ),
          ),
          const SizedBox(width: 16),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(transaction.category, style: AppTextStyles.label),
              ],
            ),
          ),

          // Amount
          Text(
            "- ${currency.format(transaction.amount)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
