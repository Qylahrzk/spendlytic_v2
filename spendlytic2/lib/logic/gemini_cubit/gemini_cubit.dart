// import 'dart:convert';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// // State
// abstract class GeminiState {}

// class GeminiInitial extends GeminiState {}

// class GeminiLoading extends GeminiState {}

// class GeminiLoaded extends GeminiState {
//   final String tip;
//   GeminiLoaded(this.tip);
// }

// class GeminiError extends GeminiState {
//   final String msg;
//   GeminiError(this.msg);
// }

// // Cubit
// class GeminiCubit extends Cubit<GeminiState> {
//   GeminiCubit() : super(GeminiInitial());

//   Future<void> getFinancialTip(double totalSpent) async {
//     emit(GeminiLoading());
//     try {
//       final apiKey = dotenv.env['GEMINI_API_KEY'];
//       if (apiKey == null) throw Exception("No API Key");

//       final url = Uri.parse(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
//       );

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {
//                   "text":
//                       "I have spent RM $totalSpent this month. Give me a 1-sentence funny or serious financial advice.",
//                 },
//               ],
//             },
//           ],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final text = data['candidates'][0]['content']['parts'][0]['text'];
//         emit(GeminiLoaded(text));
//       } else {
//         emit(GeminiError("AI Brain Freeze"));
//       }
//     } catch (e) {
//       emit(GeminiError("Failed to connect to AI"));
//     }
//   }
// }
