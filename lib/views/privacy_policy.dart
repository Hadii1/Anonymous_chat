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
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: Column(
        children: [
          TitledAppBar(
            title: 'Privacy policy',
          ),
          // SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                scrollDirection: Axis.vertical,
                child: Text(
                  _PRIVACY_POLICY,
                  style: style.bodyText,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

const String _PRIVACY_POLICY =
    '''This SERVICE is provided by and is intended for use as is.
This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.
If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. we will not use or share your information with anyone except as described in this Privacy Policy.
The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions which you can check in the profile page.

Information Collection and Use:
For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to email, location, username, phone number. The information that we request will be retained on your device and/or saved in our database.
The app does use third party services that may collect information used to identify you ( Check Service Providers and User Account below).

We might collect information about your internet connection, the equipment you use to access our Services and your usage details.
We collect this information:
	•	directly from you when you provide it to us; and/or
	•	automatically as you navigate through our Services.

The Information You Provide Us:
	•	Your preferences: Your preferences and settings such as time zone and language.
	•	Your content: Information you provide through our Services, including your reviews, reports, tags, address, and other information in your account profile.
	•	Your searches and other activities: The search terms you have looked up and results you selected.

How We Use The Information:
We use the information we collect from and about you for a variety of purposes, including to:
	•	Process and respond to your queries
	•	Understand our users (what they do on our Services, what features they like, how they use them, etc.), improve the content and features of our Services (such as by personalizing content to your interests), process and complete your transactions, and make special offers.
	•	Allow you to participate in interactive features offered through our Services.
	•	For any other purpose with your consent.
	• In any other way we may describe when you provide the information.

USER ACCOUNT:
In order to provide a better service for our users, we have a feature of user account. Now, with your privacy more important than ever before, we are clarifying the way your personal data concerning user account is collected and stored. Personal data refers to information that can identify you, such as your name, e-mail address, phone number, or any data you provide while using Prime user account.Your personal information of that kind will never be sold or rented to anyone, for any reason, at any time. We store this information in out database and we delete it once you choose to delete your account from the profile page (Delete Account) without keeping copies of it. This information will only be used to easier fulfill your requests for service, such as providing access for adding posts, and to enforce our Terms of Use.

Service Providers:
We may employ third-party companies and individuals due to the following reasons:
	•	To facilitate our Service;
	•	To provide the Service on our behalf;
	•	To perform Service-related services;
	•	To assist us in analyzing how our Service is used.
We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.

Security:
We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.

Links to Other Sites:
This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. we have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

Children’s Privacy:
These Services do not address anyone under the age of 13. we do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that we will be able to do necessary actions.

Changes to This Privacy Policy:
We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. we will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.

Contact Us:
If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at:
hadihammoud1@outlook.com\n''';
