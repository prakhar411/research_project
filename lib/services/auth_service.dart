import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'access_token';

  // In-memory fallback if plugin fails (lost on app restart)
  static String? _inMemoryToken;

  /// Save token locally
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _inMemoryToken = token;
    } on PlatformException {
      // Plugin unavailable — keep in memory and log
      _inMemoryToken = token;
      // Optionally log: print('SharedPreferences not available: $e');
      rethrow;
    } catch (e) {
      _inMemoryToken = token;
      rethrow;
    }
  }

  /// Remove token (logout)
  static Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      _inMemoryToken = null;
    } on PlatformException catch (_) {
      _inMemoryToken = null;
    } catch (_) {
      _inMemoryToken = null;
    }
  }

  /// Get token (or null)
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString(_tokenKey);
      if (t != null && t.isNotEmpty) return t;
      return _inMemoryToken;
    } on PlatformException catch (_) {
      // SharedPreferences plugin not available -> return in-memory fallback
      return _inMemoryToken;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  /// Quick local check if a token exists.
  static Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  /// Optional: verify token with backend. Returns true if backend accepts token.
  static Future<bool> verifyTokenWithServer({
    String baseUrl = 'http://10.0.2.2:8000',
  }) async {
    final token = await getToken();
    if (token == null) return false;

    try {
      // perform verification - replace with your API call
      // final res = await http.get(Uri.parse('$baseUrl/api/verify-token'), headers: {'Authorization': 'Bearer $token'});
      // return res.statusCode == 200;
      return true; // placeholder — implement your verification
    } catch (e) {
      return false;
    }
  }
}
