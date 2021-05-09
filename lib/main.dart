import 'package:anonymous_chat/views/splash_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO:
// 1- notifications

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: InitializaitonScreen(),
    ),
  );
}
