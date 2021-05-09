import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitledAppBar extends PreferredSize {
  TitledAppBar({
    this.trailing,
    this.leading,
    this.showBackarrow = false,
  }) : super(
          child: SizedBox.shrink(),
          preferredSize: Size.fromHeight(kToolbarHeight),
        );

  final Widget? trailing;
  final Widget? leading;
  final bool showBackarrow;

  void _onBackTapped(BuildContext context) => Navigator.of(context).canPop()
      ? Navigator.of(context).pop(context)
      : null;

  @override
  Widget build(BuildContext context) {
    final style = InheritedAppTheme.of(context).style;
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      automaticallyImplyMiddle: false,
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
      trailing: trailing != null ? trailing : SizedBox.shrink(),
      backgroundColor: style.backgroundColor,
      leading: leading != null
          ? leading
          : showBackarrow
              ? InkWell(
                  onTap: () => _onBackTapped(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: style.accentColor,
                    size: 22,
                  ),
                )
              : SizedBox.shrink(),
      padding: const EdgeInsetsDirectional.only(
        bottom: 8,
        start: 24,
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
