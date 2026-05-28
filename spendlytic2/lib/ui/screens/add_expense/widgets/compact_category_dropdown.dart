import 'package:flutter/material.dart';
import '../../../../data/models/category_model.dart';
import '../../../../core/app_colors.dart';

class CompactCategoryDropdown extends StatelessWidget {
  final CategoryModel selectedCategory;
  final ValueChanged<CategoryModel> onChanged;

  const CompactCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryModel>(
          value: selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AppColors.darkPurple,
          ),
          borderRadius: BorderRadius.circular(12),
          items: CategoryModel.list.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(category.icon, size: 18, color: AppColors.darkPurple),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
