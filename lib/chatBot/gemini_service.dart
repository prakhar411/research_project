import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'raksha_prompt.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyBuOZU6Yje9m1hgVNREc5f_zZ3VImzMiO4";

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse("$_endpoint?key=$_apiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": rakshaSystemPrompt},
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        debugPrint("GEMINI HTTP ERROR: ${response.body}");
        return "I’m unable to respond right now. Please contact emergency services if needed. Stay calm. I am here to help.";
      }
    } catch (e) {
      debugPrint("GEMINI EXCEPTION: $e");
      return "Connection issue detected. Please contact emergency services immediately. Stay calm. I am here to help.";
    }
  }
}
