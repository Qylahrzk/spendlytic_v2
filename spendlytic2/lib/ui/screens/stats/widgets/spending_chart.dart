import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../core/app_colors.dart';

class SpendingChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final DateTime weekStart;

  const SpendingChart({
    super.key,
    required this.transactions,
    required this.weekStart,
  });

  @override
  Widget build(BuildContext context) {
    final groupedData = _processData();
    final maxSpend = groupedData.values.fold(0.0, (p, c) => c > p ? c : p);
    // ✅ Give more headroom (1.3x) so the text label doesn't get cut off
    final maxY = maxSpend == 0 ? 100.0 : maxSpend * 1.3;

    final endOfWeek = weekStart.add(const Duration(days: 6));
    final dateRange =
        "${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd').format(endOfWeek)}";

    return Container(
      width: double.infinity,
      height: 320,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Spending",
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
                  dateRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                // ✅ 1. Disable user touch interaction (Static labels are better)
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 4, // Distance from top of bar
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // Don't show "0" labels, keep it clean
                      if (rod.toY == 0) return null;

                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(0),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Compact Font
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= 7) return const SizedBox();
                        final date = weekStart.add(
                          Duration(days: value.toInt()),
                        );
                        final isToday =
                            DateFormat('yyyy-MM-dd').format(date) ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());

                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: [
                              Text(
                                DateFormat.E().format(date),
                                style: TextStyle(
                                  color: isToday
                                      ? AppColors.secondary
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                DateFormat.d().format(date),
                                style: TextStyle(
                                  color: isToday
                                      ? AppColors.secondary
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),

                // ✅ 2. Force Tooltips to ALWAYS show on top
                barGroups: List.generate(7, (index) {
                  final date = weekStart.add(Duration(days: index));
                  final key = DateFormat('yyyy-MM-dd').format(date);
                  final amount = groupedData[key] ?? 0.0;

                  return BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: [
                      0,
                    ], // Show tooltip for rod 0 (the only rod)
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: AppColors.secondary,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white10,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _processData() {
    Map<String, double> data = {};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      data[key] = 0.0;
    }
    for (var tx in transactions) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      if (data.containsKey(key)) {
        data[key] = (data[key] ?? 0) + tx.amount;
      }
    }
    return data;
  }
}
