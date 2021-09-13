import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    this.keyboardTpe = TextInputType.text,
    required this.hint,
    required this.onChanged,
    required this.borderColor,
  });

  final Function(String) onChanged;
  final TextInputType keyboardTpe;
  final String hint;
  final Color borderColor;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;

  late Color _labelColor;

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
      keyboardAppearance: Brightness.dark,
      keyboardType: widget.keyboardTpe,
      focusNode: _focusNode,
      padding: EdgeInsets.only(bottom: 16),
      style: style.bodyText,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _labelColor,
            width: 0.35,
          ),
        ),
      ),
      placeholder: widget.hint,
      onChanged: widget.onChanged,
      placeholderStyle: style.bodyText.copyWith(color: _labelColor),
    );
  }
}
