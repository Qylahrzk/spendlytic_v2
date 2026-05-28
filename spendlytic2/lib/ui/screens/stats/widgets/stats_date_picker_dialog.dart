import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../core/app_colors.dart';

class StatsDatePickerDialog extends StatelessWidget {
  final bool isMonthlyView;
  final ValueChanged<DateTime> onDateSelected;

  const StatsDatePickerDialog({
    super.key,
    required this.isMonthlyView,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 350,
        padding: const EdgeInsets.all(12),
        child: SfDateRangePicker(
          // ✅ Dynamic View based on mode
          view: isMonthlyView
              ? DateRangePickerView.year
              : DateRangePickerView.month,

          selectionMode: DateRangePickerSelectionMode.single,
          headerHeight: 50,
          showNavigationArrow: true, // Arrows help navigation visibility
          // Colors & Style
          todayHighlightColor: AppColors.darkPurple,
          selectionColor: AppColors.darkPurple,
          headerStyle: const DateRangePickerHeaderStyle(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkPurple,
              fontSize: 18,
            ),
          ),
          yearCellStyle: const DateRangePickerYearCellStyle(
            todayTextStyle: TextStyle(
              color: AppColors.darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          monthCellStyle: const DateRangePickerMonthCellStyle(
            todayTextStyle: TextStyle(
              color: AppColors.darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Handle Selection
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is DateTime) {
              onDateSelected(args.value);
              Navigator.pop(context); // Close immediately
            }
          },
        ),
      ),
    );
  }
}
