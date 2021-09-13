import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs implements ILocalStorage {
  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static late SharedPreferences prefs;

  @override
  User? get user {
    String? user = prefs.getString('user');
    if (user == null || user.isEmpty) return null;
    return User.fromJson(user);
  }

  @override
  Future<void> setUser(User? user) async =>
      await prefs.setString('user', user == null ? '' : user.toJson());

  @override
  ThemeState get preferedTheme {
    String? theme = prefs.getString('theme');
    return theme == ThemeState.dark.toString()
        ? ThemeState.dark
        : ThemeState.light;
  }

  @override
  set preferedTheme(ThemeState theme) => prefs.setString(
        'theme',
        theme.toString(),
      );
}
