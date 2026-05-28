import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔮 FUTURE: This will call Supabase Edge Function 'analyze-receipt'
  Future<void> uploadAndAnalyzeReceipt(String imagePath) async {
    // 1. Simulate Network Delay (as if sending to Edge Function)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Mock Success Logic
    // In the real app, we would:
    // await _supabase.functions.invoke('analyze-receipt', body: { 'image': base64 });

    // For DEMO: We just return success.
    return;
  }
}
