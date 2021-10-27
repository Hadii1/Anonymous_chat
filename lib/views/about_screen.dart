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
import 'package:anonymous_chat/views/privacy_policy.dart';
import 'package:anonymous_chat/widgets/settings_tile.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
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
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => PrivacyPolicyScreen()),
                  ),
                  icon: LineariconsFree.link_1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(
                    thickness: 0.15,
                    color: style.borderColor,
                  ),
                ),
                SettingTile(
                  title: 'Rate us',
                  onTap: () => onRateUsPressed(),
                  icon: LineariconsFree.star_1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Divider(
                    thickness: 0.15,
                    color: style.borderColor,
                  ),
                ),
                SettingTile(
                  title: 'Contact us',
                  onTap: () => onCatactUsPressed(),
                  icon: LineariconsFree.users,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onRateUsPressed() async {
    InAppReview reviewInstance = InAppReview.instance;
    if (await reviewInstance.isAvailable()) {
      reviewInstance.requestReview();
    } else {
      reviewInstance.openStoreListing(appStoreId: '1564649182');
    }
  }

  onCatactUsPressed() async {
    // mailto:<email address>?subject=<subject>&body=<body>, e.g. mailto:smith@example.org?subject=News&body=New%20plugin
    bool b = await canLaunch(
        'mailto:hadihammoud1@outlook.com?subject=Anonimabody=asd');
    print(b);
    if (b) {
      launch('mailto:hadihammoud1@outlook.com?subject=Anonima&body=asd');
    }
  }
}
