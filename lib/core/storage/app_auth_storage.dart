import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized token persistence and in-memory static cache for cardriver_customer
class AppAuthStorage {
  AppAuthStorage._();

  // Static in-memory cache for customer token collected from SharedPreferences
  static String? _cachedToken;
  static String? _cachedCookie;

  /// Retrieves currently cached token synchronously if available
  static String? get currentToken => _cachedToken;

  /// Retrieves currently cached cookie synchronously if available
  static String? get currentCookie => _cachedCookie;

  /// Sets or clears the static token and cookie in memory
  static void setStaticToken(String? token) {
    if (token != null && token.trim().isNotEmpty) {
      final clean = cleanToken(token);
      if (clean.isNotEmpty) {
        _cachedToken = clean;
        _cachedCookie = 'user_token=$clean';
        return;
      }
    }
    _cachedToken = null;
    _cachedCookie = null;
  }

  /// Extracts clean raw JWT without cookies prefixes, Bearer prefixes, or quotes
  static String cleanToken(String? raw) {
    if (raw == null) return '';
    var token = raw.trim();
    if (token.contains('user_token=')) {
      token = token.split('user_token=').last.split(';').first.trim();
    } else if (token.contains('token=')) {
      token = token.split('token=').last.split(';').first.trim();
    } else if (token.contains(';')) {
      token = token.split(';').first.trim();
    }
    if (token.toLowerCase().startsWith('bearer ')) {
      token = token.substring(7).trim();
    }
    if ((token.startsWith('"') && token.endsWith('"')) ||
        (token.startsWith("'") && token.endsWith("'"))) {
      token = token.substring(1, token.length - 1).trim();
    }
    return token;
  }

  /// Checks if a JWT string is expired
  static bool isTokenExpired(String token) {
    try {
      final clean = cleanToken(token);
      final parts = clean.split('.');
      if (parts.length != 3) return false;
      final payloadBase64 = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
      final payload = jsonDecode(payloadJson);
      if (payload is Map && payload.containsKey('exp')) {
        final exp = payload['exp'];
        if (exp is num) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(
            exp.toInt() * 1000,
            isUtc: true,
          );
          return DateTime.now().toUtc().isAfter(expiryDate);
        }
      }
    } catch (_) {}
    return false;
  }

  /// Collects the authenticated user token purely from SharedPreferences and caches it statically
  static Future<String> getOrCollectToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty && !isTokenExpired(_cachedToken!)) {
      return _cachedToken!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Try auth_cookie
      final authCookie = prefs.getString('auth_cookie');
      if (authCookie != null && authCookie.trim().isNotEmpty) {
        final candidate = cleanToken(authCookie);
        if (candidate.isNotEmpty) {
          _cachedToken = candidate;
          _cachedCookie = 'user_token=$candidate';
          return candidate;
        }
      }

      // 2. Try raw token keys
      for (final key in ['token', 'auth_token', 'jwt_token']) {
        final val = prefs.getString(key);
        if (val != null && val.trim().isNotEmpty) {
          final candidate = cleanToken(val);
          if (candidate.isNotEmpty) {
            _cachedToken = candidate;
            _cachedCookie = 'user_token=$candidate';
            return candidate;
          }
        }
      }

      // 3. Try user_data JSON
      final userData = prefs.getString('user_data');
      if (userData != null && userData.trim().isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          if (userMap is Map) {
            final raw = userMap['token'] ??
                userMap['accessToken'] ??
                userMap['jwt'] ??
                userMap['authToken'];
            if (raw != null) {
              final candidate = cleanToken(raw.toString());
              if (candidate.isNotEmpty) {
                _cachedToken = candidate;
                _cachedCookie = 'user_token=$candidate';
                return candidate;
              }
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('⚠️ [AppAuthStorage] Error collecting token from SharedPreferences: $e');
    }

    return '';
  }

  /// Returns cookie format 'user_token=<token>'
  static Future<String> getOrCollectCookie() async {
    if (_cachedCookie != null && _cachedCookie!.isNotEmpty) {
      return _cachedCookie!;
    }
    final token = await getOrCollectToken();
    if (token.isNotEmpty) {
      _cachedCookie = 'user_token=$token';
      return _cachedCookie!;
    }
    return '';
  }

  /// Persists token and cookie into SharedPreferences and memory safely
  static Future<void> saveAuthToken(String token) async {
    final clean = cleanToken(token);
    if (clean.isEmpty) return;
    setStaticToken(clean);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', clean);
      await prefs.setString('auth_token', clean);
      await prefs.setString('auth_cookie', 'user_token=$clean');
    } catch (e) {
      debugPrint('⚠️ [AppAuthStorage] Error saving auth token: $e');
    }
  }

  /// Clears stored token and cookie
  static Future<void> clearAuth() async {
    setStaticToken(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('auth_token');
      await prefs.remove('auth_cookie');
      await prefs.remove('jwt_token');
    } catch (e) {
      debugPrint('⚠️ [AppAuthStorage] Error clearing auth: $e');
    }
  }
}

