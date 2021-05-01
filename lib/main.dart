import 'package:anonymous_chat/views/splash_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


// TODO: 
// 1- notifications
// 2-suggestion tiles on tap ui change
// 3- chat room screen cupertino back gesture
// 4-deleting all relevant info from the delted account
// 5- unhandled expetion permission when signing out
// 6- check ur junk hint in email forgot password
// 7- change sent email info and name from firebase console
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: InitializaitonScreen(),
    ),
  );
}
