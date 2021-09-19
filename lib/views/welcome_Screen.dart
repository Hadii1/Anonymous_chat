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
import 'package:anonymous_chat/views/login_screen.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: Column(
        children: [
          TitledAppBar(
            leading: SizedBox.shrink(),
          ),
          SizedBox(
            height: 50,
          ),
          TitleText(title: 'WELCOME SCREEN'),
       
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 48.0, left: 24, right: 24),
                  child: CtaButton(
                    onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    ),
                    text: 'START',
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

