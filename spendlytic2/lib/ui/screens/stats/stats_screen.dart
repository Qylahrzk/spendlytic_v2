import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Logic
import '../../../logic/transaction_cubit/transaction_cubit.dart';
import '../../../logic/transaction_cubit/transaction_state.dart';

// Core
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

// Widgets
import 'widgets/spending_chart.dart';
import 'widgets/monthly_pie_chart.dart';
import 'widgets/stats_date_picker_dialog.dart'; // ✅ Import New Widget
import '../../global_widgets/transaction_list_item.dart';

enum StatsViewMode { weekly, monthly }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsViewMode _viewMode = StatsViewMode.weekly;
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Food',
    'Transportation',
    'Shopping',
    'General',
    'Entertainment',
    'Bills',
  ];

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // ✅ Simplified Picker Call
  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (ctx) => StatsDatePickerDialog(
        isMonthlyView: _viewMode == StatsViewMode.monthly,
        onDateSelected: (date) => setState(() => _selectedDate = date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startRange;
    DateTime endRange;

    if (_viewMode == StatsViewMode.weekly) {
      startRange = _getStartOfWeek(_selectedDate);
      endRange = startRange.add(const Duration(days: 6));
    } else {
      startRange = _getStartOfMonth(_selectedDate);
      endRange = DateTime(startRange.year, startRange.month + 1, 0);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Statistics"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showDatePicker,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.darkPurple,
            ),
            tooltip: "Select Date",
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final rangeTransactions = state.transactions.where((tx) {
              final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
              final start = DateTime(
                startRange.year,
                startRange.month,
                startRange.day,
              );
              final end = DateTime(endRange.year, endRange.month, endRange.day);
              return txDate.compareTo(start) >= 0 && txDate.compareTo(end) <= 0;
            }).toList();

            final filteredList = _selectedFilter == 'All'
                ? rangeTransactions
                : rangeTransactions
                      .where((tx) => tx.category == _selectedFilter)
                      .toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              children: [
                // --- TOGGLE SWITCH ---
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildToggleBtn("Weekly", StatsViewMode.weekly),
                      _buildToggleBtn("Monthly", StatsViewMode.monthly),
                    ],
                  ),
                ),

                // --- CHART AREA ---
                if (_viewMode == StatsViewMode.weekly)
                  SpendingChart(
                    transactions: state.transactions,
                    weekStart: startRange,
                  )
                else
                  MonthlyPieChart(
                    transactions: rangeTransactions,
                    monthDate: startRange,
                  ),

                const SizedBox(height: 24),

                // --- 🌟 FILTER PILLS WITH FADE EFFECT ---
                // This ShaderMask creates a "Fade Out" on the right side
                // forcing the user to notice it scrolls.
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.85, 1.0], // Start fading at 85% width
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() => _selectedFilter = filter);
                            },
                            backgroundColor: AppColors.background,
                            selectedColor: AppColors.darkPurple,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- HISTORY LIST ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _viewMode == StatsViewMode.weekly
                          ? "Week (${DateFormat('d').format(startRange)} - ${DateFormat('d MMM').format(endRange)})"
                          : "Month of ${DateFormat('MMMM').format(startRange)}",
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      "${filteredList.length} items",
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (filteredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No data for this period",
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredList.map(
                    (tx) => TransactionListItem(transaction: tx),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildToggleBtn(String label, StatsViewMode mode) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewMode = mode;
            _selectedDate = DateTime.now();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.darkPurple : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
