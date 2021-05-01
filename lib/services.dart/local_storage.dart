import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() => _instance;

  LocalStorage._internal();

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static late SharedPreferences prefs;

  User? get user {
    String? user = prefs.getString('user');
    if (user == null || user.isEmpty) return null;
    return User.fromJson(user);
  }

  Future<void> setUser(User? user) async =>
      await prefs.setString('user', user == null ? '' : user.toJson());

  ThemeState get preferedTheme {
    String? theme = prefs.getString('theme');
    return theme == ThemeState.dark.toString()
        ? ThemeState.dark
        : ThemeState.light;
  }

  set preferedTheme(ThemeState theme) => prefs.setString(
        'theme',
        theme.toString(),
      );
}
