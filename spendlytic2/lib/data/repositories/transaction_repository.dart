import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class TransactionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- TRANSACTIONS ---

  Future<List<TransactionModel>> getTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('transaction_date', ascending: false); // Newest first

      return (response as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    } catch (e) {
      print("⚠️ FETCH ERROR: $e"); // Check your console for this!
      return [];
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // ✅ FORCE UTC TIME to prevent timezone issues
      final now = DateTime.now().toUtc().toIso8601String();

      await _supabase.from('transactions').insert({
        'user_id': user.id,
        'title': title,
        'amount': amount,
        'category': category,
        'transaction_date': now, // Must match column type (timestamptz)
        'created_at': now,
      });
      print("✅ Insert Success: $title - $amount");
    } catch (e) {
      print("❌ INSERT ERROR: $e"); // THIS WILL TELL YOU THE TRUTH
      throw Exception("Failed to save transaction: $e");
    }
  }

  // --- BUDGETS ---

  Future<List<BudgetModel>> getBudgets() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', userId);

      return (response as List).map((e) => BudgetModel.fromJson(e)).toList();
    } catch (e) {
      print("⚠️ Budget Fetch Error: $e");
      return [];
    }
  }

  Future<void> setBudget(String category, double amount) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Delete existing (Avoid duplicates logic)
      await _supabase.from('budgets').delete().match({
        'user_id': userId,
        'category': category,
      });

      // 2. Insert new
      await _supabase.from('budgets').insert({
        'user_id': userId,
        'category': category,
        'amount': amount,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print("❌ Set Budget Error: $e");
      throw Exception("Failed to set budget");
    }
  }

  Future<double> getTotalBudget() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0.0;

      final response = await _supabase
          .from('budgets')
          .select('amount')
          .eq('user_id', userId);

      final List<dynamic> data = response;
      double total = 0.0;
      for (var row in data) {
        total += (row['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }
}
