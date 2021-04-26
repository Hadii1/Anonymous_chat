import 'package:flutter/material.dart';

import 'package:anonymous_chat/utilities/theme_widget.dart';

class SearchField extends StatefulWidget {
  final String hint;
  final Function(String) onChanged;

  SearchField({
    required this.hint,
    required this.onChanged,
  });

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return TextField(
      onChanged: widget.onChanged,
      autocorrect: false,
      controller: _controller,
      textAlign: TextAlign.center,
      style: style.bodyText,
      cursorColor: style.accentColor,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: widget.hint,
        prefixIconConstraints: BoxConstraints(minHeight: 32, maxWidth: 32),
        suffixIconConstraints: BoxConstraints(minHeight: 32, minWidth: 30),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Icon(
            Icons.search,
            color: style.searchBarHintColor,
            size: 21,
          ),
        ),
        hintStyle: style.bodyText.copyWith(color: style.searchBarHintColor,fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.3,
            color: style.accentColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.15,
            color: style.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 0.3,
            color: style.accentColor,
          ),
        ),
      ),
    );
  }
}
