import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationService {
  // ⚠️ Android emulator uses 10.0.2.2
  static const String baseUrl = "http://10.0.2.2:8000";
  static Future<Map<String, dynamic>> verifyStructured(
      Map<String, dynamic> payload) async {

    final response = await http.post(
      Uri.parse("$baseUrl/verify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Verification failed");
    }
  }

  static Future<Map<String, dynamic>> verifyText(String text) async {
    final url = Uri.parse("$baseUrl/verify");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": text,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["result"];
    } else {
      throw Exception("Verification failed");
    }
  }
}
