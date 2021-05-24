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

import 'dart:async';

import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBox extends StatefulWidget {
  final Function(String) onSendPressed;
  final Function(bool) onTypingStateChange;

  final bool isContactBlocked;

  const MessageBox({
    required this.onSendPressed,
    required this.onTypingStateChange,
    required this.isContactBlocked,
  });

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _TypingIndicatorThrottle {
  final void Function(bool) f;

  final Duration waitingTime;

  DateTime? lastCallTime;

  _TypingIndicatorThrottle({
    required this.waitingTime,
    required this.f,
  });

  Timer? timer;
  bool lastState = false;

  void onType() {
    if (timer != null) {
      _restartTimer();
    }
    // First Call
    if (lastCallTime == null) {
      lastCallTime = DateTime.now();
      f(true);

      timer = Timer(waitingTime, () {
        f(false);
      });
    } else {
      if (DateTime.now().difference(lastCallTime!) >= waitingTime &&
          !lastState) {
        lastCallTime = DateTime.now();
        lastState = true;
        f(true);
      }
    }
  }

  _restartTimer() {
    timer!.cancel();
    timer = Timer(waitingTime, () {
      f(false);
      lastState = false;
    });
  }
}

class _MessageBoxState extends State<MessageBox> {
  final _controller = TextEditingController();

  @override
  void initState() {
    _TypingIndicatorThrottle throttle = _TypingIndicatorThrottle(
      waitingTime: Duration(seconds: 2),
      f: widget.onTypingStateChange,
    );

    _controller.addListener(() {
      setState(() {
        throttle.onType();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(MessageBox oldWidget) {
    if (oldWidget.isContactBlocked != widget.isContactBlocked) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
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
                enabled: !widget.isContactBlocked,
                autocorrect: false,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
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
