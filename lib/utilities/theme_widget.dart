import 'package:flutter/material.dart';

import 'package:anonymous_chat/services.dart/shared_preferences.dart';
import 'package:flutter/services.dart';

enum ThemeState {
  dark,
  light,
}

class AppStyle {
  AppStyle({
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
    required this.dimmedColorText,
    required this.backgroundContrastColor,
  });

  static const hof = Color(0xff484848);
  static const lightBlack = Color(0xff2e2e2e);
  static const foggy = Color(0xff767676);
  static const secondaryTextColor = Colors.white54;

  static const ambientYellow = Color(0xff00FFC1);
  // static const ambientYellow = Color(0xffffe600);

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
  final Color dimmedColorText;

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

  static final AppStyle darkStyle = AppStyle(
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
      fontFamily: 'SourceSansPro',
    ),
    titleStyle: TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      fontFamily: 'SourceSansPro',
      wordSpacing: 1.2,
    ),
    appBarTextStyle: TextStyle(
      fontSize: 21,
      fontFamily: 'Playfair',
      color: Colors.white,
    ),
    title2Style: TextStyle(
      color: Colors.white,
      fontFamily: 'SourceSansPro',
      fontSize: 23,
      wordSpacing: 1.2,
      fontWeight: FontWeight.w600,
    ),
    title3Style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      wordSpacing: 1.2,
      fontFamily: 'SourceSansPro',
    ),
    bodyText: TextStyle(
      color: Colors.white,
      fontFamily: 'SourceSansPro',
      fontSize: 14,
    ),
    dimmedColorText: Colors.white.withOpacity(0.6),
    chatHeaderLetter: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontFamily: 'SourceSansPro',
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
  AppStyle _style = AppStyle.darkStyle;

  void toggleTheme() {
    setState(() {
      ThemeState currentTheme = SharedPrefs().preferedTheme;
      if (currentTheme == ThemeState.dark) {
        SharedPrefs().preferedTheme = ThemeState.light;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        _style = AppStyle.darkStyle;
      } else {
        SharedPrefs().preferedTheme = ThemeState.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        _style = AppStyle.darkStyle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheming(
      child: widget.child,
      style: _style,
      state: this,
    );
  }
}

class AppTheming extends InheritedWidget {
  AppTheming({
    required this.child,
    required this.style,
    required this.state,
  }) : super(child: child);

  final Widget child;
  final AppStyle style;
  final _AppThemeState state;

  static AppTheming of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheming>() ??
        AppTheming(
          child: SizedBox.shrink(),
          style: AppStyle.darkStyle,
          state: _AppThemeState(),
        );
  }

  @override
  bool updateShouldNotify(AppTheming oldWidget) {
    return oldWidget.style != this.style;
  }
}
