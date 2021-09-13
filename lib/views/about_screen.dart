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
import 'package:anonymous_chat/widgets/settings_tile.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';

class AboutScreen extends StatelessWidget {
  // TODO: Launching Links
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TitledAppBar(
            previousPageTitle: 'Settings',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SettingTile(
                  title: 'Privacy Policy',
                  onTap: () {},
                  icon: LineariconsFree.link_1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    thickness: 0.15,
                    color: style.borderColor,
                  ),
                ),
                SettingTile(
                  title: 'Rate us',
                  onTap: () {},
                  icon: LineariconsFree.star_1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    thickness: 0.15,
                    color: style.borderColor,
                  ),
                ),
                SettingTile(
                  title: 'Contact us',
                  onTap: () {},
                  icon: LineariconsFree.users,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
