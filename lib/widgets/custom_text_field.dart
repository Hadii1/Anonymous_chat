import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/cupertino.dart';


class CustomTextField extends StatefulWidget {
  const CustomTextField({
    this.keyboardTpe = TextInputType.text,
    required this.hint,
    this.onSubmitted,
    required this.onChanged,
    required this.borderColor,
    this.textEditingAction,
    this.prefix,
    this.dimHint = false,
  });

  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final TextInputAction? textEditingAction;
  final TextInputType keyboardTpe;
  final String? prefix;
  final String hint;
  final bool dimHint;
  final Color borderColor;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;

  late Color labelColor;

  @override
  void initState() {
    labelColor = widget.borderColor;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
      upperBound: 1,
      lowerBound: 0.5,
      value: 1,
    );

    _animationController.addListener(() {
      setState(() {
        labelColor = widget.borderColor.withOpacity(_animationController.value);
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
      prefix: widget.prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                widget.prefix! + '  ',
                style: TextStyle(
                  color: labelColor,
                ),
              ),
            ),
      keyboardType: widget.keyboardTpe,
      focusNode: _focusNode,
      onSubmitted: widget.onSubmitted,
      padding: EdgeInsets.only(bottom: 12),
      textInputAction: widget.textEditingAction,
      style: style.bodyText,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: labelColor,
            width: 0.35,
          ),
        ),
      ),
      placeholder: widget.hint,
      onChanged: widget.onChanged,
      placeholderStyle: style.bodyText.copyWith(
        color: widget.dimHint ? style.dimmedColorText : labelColor,
      ),
    );
  }
}
