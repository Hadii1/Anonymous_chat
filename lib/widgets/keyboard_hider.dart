import 'package:flutter/material.dart';

class KeyboardHider extends StatelessWidget {
  final Widget child;

  const KeyboardHider({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //So that the keyboard hides when the user taps anywhere outside
      onTap: () {
        FocusScopeNode node = FocusScope.of(context);
        if (!node.hasPrimaryFocus) {
          node.unfocus();
        }
      },
      child: child,
    );
  }
}
