import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  PasswordField({
    required this.onChanged,
    required this.borderColor,
  });
  final Function(String) onChanged;
  final Color borderColor;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Color _labelColor;
  bool _obsecured = true;

  @override
  void initState() {
    _labelColor = widget.borderColor;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
      upperBound: 1,
      lowerBound: 0.5,
      value: 1,
    );

    _animationController.addListener(() {
      setState(() {
        _labelColor =
            widget.borderColor.withOpacity(_animationController.value);
      });
    });

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return CupertinoTextField(
      focusNode: _focusNode,
      keyboardAppearance: Brightness.dark,
      keyboardType: TextInputType.text,
      padding: EdgeInsets.only(bottom: 16),
      suffix: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            _obsecured = !_obsecured;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: _obsecured
                ? Icon(
                    Icons.visibility,
                    color: style.iconColors,
                  )
                : Container(
                    child: Icon(
                      Icons.visibility_off,
                      color: style.iconColors,
                    ),
                  ),
          ),
        ),
      ),
      style: style.bodyText,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _labelColor,
            width: 0.35,
          ),
        ),
      ),
      placeholder: 'Password',
      onChanged: widget.onChanged,
      obscureText: _obsecured,
      placeholderStyle: style.bodyText.copyWith(color: _labelColor),
    );
  }
}
