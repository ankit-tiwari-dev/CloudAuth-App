import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _currentUserKey = 'current_user';
  static const String _bookCachePrefix = 'cached_books_';
  static const String _passwordHashesKey = 'password_hashes';

  static Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<void> savePasswordHash(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_passwordHashesKey) ?? '{}';
    final data = json.decode(existing) as Map<String, dynamic>;
    data[email] = sha256.convert(utf8.encode(password)).toString();
    await prefs.setString(_passwordHashesKey, json.encode(data));
  }

  static Future<void> saveBooks(String uid, List<BookModel> books) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = books.map((book) => book.toMap()).toList();
    await prefs.setString('$_bookCachePrefix$uid', json.encode(encoded));
  }

  static Future<List<BookModel>> getBooks(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_bookCachePrefix$uid');
    if (raw == null || raw.isEmpty) return <BookModel>[];
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((item) => BookModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
