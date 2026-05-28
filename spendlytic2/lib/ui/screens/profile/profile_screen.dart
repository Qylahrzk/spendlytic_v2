import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/profile_cubit/profile_cubit.dart';
import '../../../logic/profile_cubit/profile_state.dart';

// Core
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile data when the screen initializes
    context.read<ProfileCubit>().loadProfile();
  }

  // Helper: Show confirmation dialog before logging out
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              // Perform the actual sign out
              context.read<AuthenticationCubit>().signOut();
            },
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Default placeholders
          String name = "Student";
          String email = "Loading...";
          String initial = "S";

          // Update data if loaded
          if (state is ProfileLoaded) {
            name = state.user.fullName;
            email = state.user.email; // ✅ Now using real email
            if (name.isNotEmpty) {
              initial = name[0].toUpperCase();
            }
          }

          return Column(
            children: [
              // 🌟 1. The Gradient Header
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // The Background Curve
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppColors.mainGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                  ),

                  // The Page Title
                  const Positioned(
                    top: 60,
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // The Floating Avatar
                  Positioned(
                    bottom: -50,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.background,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60), // Space for the floating avatar
              // 2. User Info
              Text(name, style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTextStyles.body.copyWith(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // 3. Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildSettingItem(Icons.person_outline, "Edit Profile", () {
                      // TODO: Navigate to Edit Profile Screen
                    }),
                    _buildSettingItem(
                      Icons.notifications_outlined,
                      "Notifications",
                      () {},
                    ),
                    _buildSettingItem(Icons.lock_outline, "Security", () {}),

                    const SizedBox(height: 20),

                    // Logout Button (Red styled)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                          ),
                        ),
                        title: const Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.error,
                        ),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper Widget for standard settings items
  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.darkPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
