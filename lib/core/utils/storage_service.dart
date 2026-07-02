// Lightweight JSON persistence via shared_preferences.
// Saves the key operational collections (patients, appointments, invoices,
// staff, leads, finance) so user changes survive app restarts.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  static bool getBool(String key, bool fallback) => _prefs?.getBool(key) ?? fallback;
  static int getInt(String key, int fallback) => _prefs?.getInt(key) ?? fallback;
  static String getString(String key, String fallback) => _prefs?.getString(key) ?? fallback;

  static void setBool(String key, bool v) => _prefs?.setBool(key, v);
  static void setInt(String key, int v) => _prefs?.setInt(key, v);
  static void setString(String key, String v) => _prefs?.setString(key, v);

  // ── JSON list helpers ────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> loadList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static void saveList(String key, List<Map<String, dynamic>> data) {
    _prefs?.setString(key, jsonEncode(data));
  }

  // ── Convenience: save any list of items that have toJson() ──────────────────

  static void saveObjects(String key, List<dynamic> items) {
    saveList(key, items.map((e) => e.toJson() as Map<String, dynamic>).toList());
  }
}
