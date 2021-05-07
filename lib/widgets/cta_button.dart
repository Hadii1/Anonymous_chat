import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:flutter/material.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({
    required this.onPressed,
    required this.text,
    this.isPrimary = true,
  });

  final Function() onPressed;
  final bool isPrimary;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = InheritedAppTheme.of(context).style;
    return SizedBox(
      height: 50,
      width: double.maxFinite,
      child: TextButton(
        child: Text(
          text,
          style: style.bodyText.copyWith(
            color: isPrimary ? style.accentColor : style.borderColor,
          ),
        ),
        style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(style.accentColor.withOpacity(0.1)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isPrimary ? style.accentColor : style.borderColor,
                  width: 0.35,
                ),
              ),
            )),
        onPressed: onPressed,
      ),
    );
  }
}
