import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../../../logic/profile_cubit/profile_cubit.dart';
import '../../../../logic/profile_cubit/profile_state.dart';

// Core
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Default placeholder
        String displayName = "Student";

        // ✅ Check if data arrived
        if (state is ProfileLoaded) {
          displayName = state.user.fullName;

          // Optional: Display only first name if it's long
          if (displayName.contains(" ")) {
            displayName = displayName.split(" ")[0];
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good morning,",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName, // ✅ Uses dynamic name
                  style: AppTextStyles.h2,
                ),
              ],
            ),

            // Profile Icon
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person, color: AppColors.primaryDark),
                onPressed: () {
                  // Navigate to Profile Tab (Tab index 4)
                  // Or open settings
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
