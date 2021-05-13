import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledAppBar extends PreferredSize {
  TitledAppBar({
    this.trailing,
    this.leading,
    this.previousPageTitle,
  }) : super(
          child: SizedBox.shrink(),
          preferredSize: Size.fromHeight(kToolbarHeight),
        );

  final Widget? trailing;
  final Widget? leading;
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    final style = InheritedAppTheme.of(context).style;

    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      automaticallyImplyMiddle: false,
      previousPageTitle: previousPageTitle,
      middle: Text(
        'ANONIMA',
        style: TextStyle(
          color: style.accentColor,
          fontSize: 24,
          letterSpacing: 4,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserat',
        ),
      ),
      trailing: trailing,
      backgroundColor: style.backgroundColor,
      leading: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => Navigator.of(context).pop(),
          child: leading ??
              Row(
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
      padding: const EdgeInsetsDirectional.only(
        bottom: 8,
        start: 12,
        end: 24,
        top: 8,
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
