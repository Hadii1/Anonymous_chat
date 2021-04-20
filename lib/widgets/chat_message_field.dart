// Copyright 2021 hadihammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  final Function(String) onSendPressed;
  final Function(bool) onFocusChanged;

  const MessageBox({
    required this.onSendPressed,
    required this.onFocusChanged,
  });

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(() {
      widget.onFocusChanged(_focusNode.hasPrimaryFocus);
    });

    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(8.0),
      color: style.backgroundColor,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autocorrect: false,
                focusNode: _focusNode,
                cursorColor: style.accentColor,
                style: style.bodyText,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: style.bodyText
                      .copyWith(color: ApplicationStyle.secondaryTextColor),
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  fillColor: style.backgroundColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      width: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      width: 0.15,
                      color: style.accentColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      width: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: _controller.text.isEmpty
                    ? Icon(
                        Icons.send,
                        color: Colors.grey,
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            widget.onSendPressed(_controller.text);
                            _controller.clear();
                          });
                        },
                        child: Icon(
                          Icons.send,
                          color: style.accentColor,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
