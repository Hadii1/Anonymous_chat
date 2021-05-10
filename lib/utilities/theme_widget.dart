import 'package:flutter/material.dart';

import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:flutter/services.dart';

enum ThemeState {
  dark,
  light,
}

class ApplicationStyle {
  ApplicationStyle({
    required this.accentColor,
    required this.backgroundColor,
    required this.chipCheckColor,
    required this.titleStyle,
    required this.searchBarHintColor,
    required this.title2Style,
    required this.bodyText,
    required this.appBarColor,
    required this.chipBackgroundColor,
    required this.borderColor,
    required this.chatHeaderMsgTime,
    required this.chipRecentIconColor,
    required this.iconColors,
    required this.chatTextFieldColor,
    required this.switchTrackColor,
    required this.chatHeaderLetter,
    required this.loadingBarColor,
    required this.sentMessageBubbleColor,
    required this.receivedMessageBubbleColor,
    required this.chatBubbleTextColor,
    required this.title3Style,
    required this.smallTextStyle,
    required this.appBarTextStyle,
    required this.backgroundContrastColor,
  });

  static const hof = Color(0xff484848);
  static const lightBlack = Color(0xff2e2e2e);
  static const foggy = Color(0xff767676);
  static const secondaryTextColor = Colors.white54;

  // static const green = Color(0xff00bc48);
  static const ambientYellow = Color(0xff00FFC1);

  final Color accentColor;
  final Color backgroundColor;
  final Color backgroundContrastColor;

  final Color searchBarHintColor;
  final Color chatHeaderMsgTime;
  final Color chipCheckColor;
  final Color chipBackgroundColor;
  final Color chipRecentIconColor;
  final Color chatTextFieldColor;
  final Color switchTrackColor;
  final Color appBarColor;
  final Color borderColor;
  final Color iconColors;
  final Color loadingBarColor;

  final Color sentMessageBubbleColor;
  final Color receivedMessageBubbleColor;
  final Color chatBubbleTextColor;

  final TextStyle titleStyle;
  final TextStyle title2Style;
  final TextStyle smallTextStyle;
  final TextStyle bodyText;

  final TextStyle chatHeaderLetter;
  final TextStyle appBarTextStyle;
  final TextStyle title3Style;

  static final ApplicationStyle darkStyle = ApplicationStyle(
    appBarColor: lightBlack,
    chatBubbleTextColor: Colors.white,
    chatHeaderMsgTime: foggy,
    backgroundContrastColor: Colors.white,
    chatTextFieldColor: Colors.white,
    switchTrackColor: foggy,
    accentColor: ambientYellow,
    searchBarHintColor: foggy,
    backgroundColor: Colors.black,
    chipCheckColor: ambientYellow,
    borderColor: Colors.white,
    sentMessageBubbleColor: ambientYellow,
    receivedMessageBubbleColor: lightBlack,
    chipRecentIconColor: Colors.white,
    chipBackgroundColor: lightBlack,
    iconColors: hof,
    loadingBarColor: Colors.white,
    smallTextStyle: TextStyle(
      color: foggy,
      fontSize: 13,
    ),
    titleStyle: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      wordSpacing: 1.5,
    ),
    appBarTextStyle: TextStyle(
      fontSize: 21,
      color: Colors.white,
    ),
    title2Style: TextStyle(
      color: Colors.white,
      fontFamily: 'Montserat',
      fontSize: 21,
      wordSpacing: 1.2,
      fontWeight: FontWeight.bold,
    ),
    title3Style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      wordSpacing: 1.2,
    ),
    bodyText: TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
    chatHeaderLetter: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  );
}

class AppTheme extends StatefulWidget {
  final Widget child;

  const AppTheme({required this.child});

  @override
  _AppThemeState createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  ApplicationStyle _style = ApplicationStyle.darkStyle;

  void toggleTheme() {
    setState(() {
      ThemeState currentTheme = LocalStorage().preferedTheme;
      if (currentTheme == ThemeState.dark) {
        LocalStorage().preferedTheme = ThemeState.light;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        _style = ApplicationStyle.darkStyle;
      } else {
        LocalStorage().preferedTheme = ThemeState.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        _style = ApplicationStyle.darkStyle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedAppTheme(
      child: widget.child,
      style: _style,
      state: this,
    );
  }
}

class InheritedAppTheme extends InheritedWidget {
  InheritedAppTheme({
    required this.child,
    required this.style,
    required this.state,
  }) : super(child: child);

  final Widget child;
  final ApplicationStyle style;
  final _AppThemeState state;

  static InheritedAppTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedAppTheme>() ??
        InheritedAppTheme(
          child: SizedBox.shrink(),
          style: ApplicationStyle.darkStyle,
          state: _AppThemeState(),
        );
  }

  @override
  bool updateShouldNotify(InheritedAppTheme oldWidget) {
    return oldWidget.style != this.style;
  }
}
