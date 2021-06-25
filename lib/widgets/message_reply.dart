// Copyright 2021 Hadi Hammoud
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

// Copyright 2021 Hadi Hammoud
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

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class MessageReplyPreview extends StatefulWidget {
  final Message? message;
  final Function() onCancelPressed;

  const MessageReplyPreview({
    required this.message,
    required this.onCancelPressed,
  });
  @override
  _MessageReplyPreviewState createState() => _MessageReplyPreviewState();
}

class _MessageReplyPreviewState extends State<MessageReplyPreview>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    );

    if (widget.message != null) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(MessageReplyPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.message != oldWidget.message) {
      if (widget.message != null) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 350)
      ..forward();
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 350)
      ..reverse();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _appearanceController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        child: widget.message == null
            ? SizedBox(
                height: _appearanceController.upperBound,
              )
            : Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: style.accentColor,
                        width: 4,
                      ),
                    ),
                    color: style.accentColor.withOpacity(0.15)),
                child: widget.message!.type == MessageType.TEXT_ONLY ||
                        widget.message!.type == MessageType.TEXT_ON_MEDIA ||
                        widget.message!.type == MessageType.TEXT_ON_TEXT
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.message!.content!,
                            style: TextStyle(color: Colors.white),
                          ),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: style.accentColor,
                            onTap: () {
                              widget.onCancelPressed();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                        ],
                      )
                    : SizedBox.shrink(),
              ),
      ),
    );
  }
}
