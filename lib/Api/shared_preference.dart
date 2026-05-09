import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ---------------- TOKEN ----------------

  static Future<void> setToken(String token) async {
    await init();
    await _prefs!.setString('token', token);
  }

  static String? getToken() {
    return _prefs?.getString('token');
  }

  static Future<void> clearToken() async {
    await init();
    await _prefs!.remove('token');
  }

  // ---------------- FCM TOKEN ----------------

  static Future<void> setFCMToken(String token) async {
    await init();
    await _prefs!.setString('fcm_token', token);
  }

  static String? getFCMToken() {
    return _prefs?.getString('fcm_token');
  }

  // ---------------- USER INFO ----------------

  static Future<void> setUserName(String name) async {
    await init();
    await _prefs!.setString('user_name', name);
  }

  static String? getUserName() {
    return _prefs?.getString('user_name');
  }

  static Future<void> setEmail(String email) async {
    await init();
    await _prefs!.setString('email', email);
  }

  static String? getEmail() {
    return _prefs?.getString('email');
  }

  static Future<void> setProfileImage(String image) async {
    await init();
    await _prefs!.setString('profile_image', image);
  }

  static String? getProfileImage() {
    return _prefs?.getString('profile_image');
  }

  // ---------------- BOOKMARKS ----------------

  static Future<void> saveBookmarks(List<String> ids) async {
    await init();
    await _prefs!.setStringList('bookmarks', ids);
  }

  static List<String> getBookmarks() {
    return _prefs?.getStringList('bookmarks') ?? [];
  }

  // ---------------- LOGIN STATUS ----------------

  static Future<void> setLogin(bool value) async {
    await init();
    await _prefs!.setBool('is_login', value);
  }

  static bool isLogin() {
    return _prefs?.getBool('is_login') ?? false;
  }

  // ---------------- LOGOUT ----------------

  static Future<void> logout() async {
    await init();
    await _prefs!.clear();
  }
}