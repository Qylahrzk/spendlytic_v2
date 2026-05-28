import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/category_model.dart'; // ✅ Import Centralized Model

// Core
import '../../../../core/app_colors.dart';

class MonthlyPieChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final DateTime monthDate;

  const MonthlyPieChart({
    super.key,
    required this.transactions,
    required this.monthDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Group Data by Category
    final categoryTotals = <String, double>{};
    double totalSpent = 0;

    for (var tx in transactions) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
      totalSpent += tx.amount;
    }

    // Colors for different categories (cycling)
    final colors = [
      AppColors.secondary, // Cyan
      Colors.amberAccent,
      Colors.orangeAccent,
      Colors.lightBlueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.tealAccent,
    ];

    int colorIndex = 0;

    // Sort so biggest slices are first (looks better)
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sortedEntries.map((entry) {
      final percentage = totalSpent == 0
          ? 0.0
          : (entry.value / totalSpent) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      // ✅ Get correct icon from the shared model
      final categoryModel = CategoryModel.fromName(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        // ✅ Show Percentage AND Value
        title:
            '${percentage.toStringAsFixed(0)}%\nRM ${entry.value.toStringAsFixed(0)}',
        radius: 60, // Slightly bigger to fit text
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors
              .black87, // Dark text is usually better on bright pastel colors
        ),
        badgeWidget: _Badge(
          icon: categoryModel.icon, // ✅ Uses correct icon
          color: color,
        ),
        badgePositionPercentageOffset: 1.4, // Push icon further out
      );
    }).toList();

    return Container(
      width: double.infinity,
      height: 400, // Taller to fit badges
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.mainGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly Breakdown",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(monthDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40), // More space for badges at top
          Expanded(
            child: sections.isEmpty
                ? const Center(
                    child: Text(
                      "No Data",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40, // Donut hole
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: true),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            "Total: RM ${totalSpent.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Badge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }
}
