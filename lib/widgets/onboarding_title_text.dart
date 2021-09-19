import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  TitleText({
    required this.title,
    this.subtitle,
  });
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: style.titleStyle,
          ),
          subtitle == null
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style:
                        style.bodyText.copyWith(color: style.dimmedColorText),
                  ),
                ),
        ],
      ),
    );
  }
}
