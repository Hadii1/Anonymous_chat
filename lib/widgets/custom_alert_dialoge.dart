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

import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class CustomAlertDialoge extends StatelessWidget {
  final String msg;
  final String actionMsg;
  final Function() onAction;

  const CustomAlertDialoge({
    required this.msg,
    required this.actionMsg,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              style.accentColor.withOpacity(0.6)
            ],
            stops: [0.7, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg,
                style: style.bodyText,
              ),
              SizedBox(
                height: 24,
              ),
              TextButton(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    actionMsg.toUpperCase(),
                    style: style.bodyText.copyWith(
                      color: style.borderColor,
                    ),
                  ),
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      style.accentColor.withOpacity(0.1)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: style.accentColor,
                        width: 0.35,
                      ),
                    ),
                  ),
                ),
                onPressed: onAction,
              )
            ],
          ),
        ));
  }
}
