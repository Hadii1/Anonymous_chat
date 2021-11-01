import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledAppBar extends PreferredSize {
  TitledAppBar({
    this.trailing,
    this.leading,
    this.previousPageTitle,
    this.title,
  }) : super(
          child: SizedBox.shrink(),
          preferredSize: Size.fromHeight(kToolbarHeight),
        );

  final Widget? trailing;
  final Widget? leading;
  final String? title;
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;

    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      automaticallyImplyMiddle: false,
      previousPageTitle: previousPageTitle,
      middle: title != null
          ? Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.backgroundContrastColor,
                fontSize: 24,
                fontFamily: 'Playfair',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            )
          : Text(
              'PRIME',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.accentColor,
                fontSize: 24,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair',
              ),
            ),
      trailing: () {
        if (trailing != null) return trailing;
        // return SizedBox(
        //   width: 80,
        // );
      }(),
      backgroundColor: style.backgroundColor,
      leading: SizedBox(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => Navigator.of(context).pop(),
            child: leading ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.back,
                      color: style.accentColor,
                      size: 24,
                    ),
                    previousPageTitle != null
                        ? Text(
                            previousPageTitle!,
                            style: TextStyle(
                              color: style.accentColor,
                              fontSize: 16,
                            ),
                          )
                        : SizedBox.shrink()
                  ],
                ),
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.only(
        bottom: 8,
        start: 12,
        end: 24,
        top: 0,
      ),
      border: Border(
        bottom: BorderSide(
          color: style.borderColor,
          width: 0.15,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
