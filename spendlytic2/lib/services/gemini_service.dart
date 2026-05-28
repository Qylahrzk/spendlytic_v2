import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeminiService {
  // Using Supabase client directly is often easier for Auth headers
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> scanReceipt(Uint8List imageBytes) async {
    try {
      // 1. Call the Edge Function
      final response = await _supabase.functions.invoke(
        'gemini-flash',
        body: {'imageBytes': base64Encode(imageBytes)},
      );

      if (response.status != 200) {
        throw Exception("Edge Function Error: ${response.status}");
      }

      // 2. Parse Data
      final data =
          response.data; // Supabase SDK parses JSON automatically usually

      // Handle if data is string or map depending on SDK version
      Map<String, dynamic> jsonMap;
      if (data is String) {
        jsonMap = jsonDecode(data);
      } else {
        jsonMap = Map<String, dynamic>.from(data);
      }

      if (jsonMap.containsKey('items')) {
        return List<Map<String, dynamic>>.from(jsonMap['items']);
      }

      return [];
    } catch (e) {
      print("❌ Gemini Scan Error: $e");
      throw Exception('Failed to scan receipt. Please try again.');
    }
  }
}
