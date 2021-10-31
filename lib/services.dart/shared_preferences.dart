import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs implements ILocalPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static late SharedPreferences prefs;

  @override
  LocalUser? get user {
    String? user = prefs.getString('user');
    if (user == null || user.isEmpty) return null;
    return LocalUser.fromJson(user);
  }

  @override
  Future<void> setUser(LocalUser? user) async =>
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

  @override
  Future<void> setSyncingDate(int millisSinceEpoch) async =>
      await prefs.setInt('lastSyncingDate', millisSinceEpoch);

  @override
  int get lastSyncingDate => prefs.getInt('lastSyncingDate') ?? 0;
}
