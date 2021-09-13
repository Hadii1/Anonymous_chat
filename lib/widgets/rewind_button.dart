import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class RewindButton extends StatelessWidget {
  final Function() onPressed;

  const RewindButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.accentColor,
      ),
      child: Center(
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            Icons.replay,
            size: 35,
          ),
        ),
      ),
    );
  }
}
