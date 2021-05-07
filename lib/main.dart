import 'package:anonymous_chat/views/splash_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO:
// 1- notifications
// 6- check ur junk hint in email forgot password
// 7- change sent email info and name from firebase console
// 8- Blocking users
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: InitializaitonScreen(),
    ),
  );
}
