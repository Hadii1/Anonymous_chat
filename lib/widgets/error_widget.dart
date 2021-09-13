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

import 'dart:math';

import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:flutter/material.dart';

const _errorMsgs = [
  'Unable to load data.',
  'An error occured.',
  'Something went wrong.'
];

class ErrorDisplayingWidget extends StatelessWidget {
  final Function() onRetry;
  final String? errorMessage;

  const ErrorDisplayingWidget({
    required this.onRetry,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Fader(
      duration: Duration(milliseconds: 250),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 50,
              color: Colors.grey,
            ),
            Text(
              errorMessage == null
                  ? _errorMsgs[Random().nextInt(3)]
                  : errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: style.accentColor,
                ),
                child: Text(
                  'RETRY',
                  style: style.title2Style,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
