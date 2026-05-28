import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }

  // Optional: Update profile method for the future
  Future<void> updateProfile(String name) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('profiles')
        .update({'full_name': name})
        .eq('id', userId);
  }
}
