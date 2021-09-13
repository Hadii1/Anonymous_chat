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
import 'package:anonymous_chat/widgets/age.dart';
import 'package:anonymous_chat/widgets/country_widget.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/gender.dart';
import 'package:anonymous_chat/widgets/step_counter_bar.dart';
import 'package:anonymous_chat/widgets/top_padding.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingInfo {
  factory OnboardingInfo.defaultValue() => OnboardingInfo(
        gender: '',
        age: 867618000000,
      );

  String? gender;
  int? age;
  CountryInfo? country;

  OnboardingInfo({
    this.gender,
    this.age,
    this.country,
  });
}

final onboardingInfoProvider =
    StateNotifierProvider.autoDispose<OnboardingInfoNotifier, OnboardingInfo>(
  (_) => OnboardingInfoNotifier(),
);

class OnboardingInfoNotifier extends StateNotifier<OnboardingInfo> {
  OnboardingInfoNotifier()
      : super(
          OnboardingInfo.defaultValue(),
        );

  set gender(String gender) {
    state.gender = gender;
    state = state;
  }

  set age(int age) {
    state.age = age;
    state = state;
  }

  set country(CountryInfo country) {
    state.country = country;
    state = state;
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController pageController;
  int activeIndex = 0;

  @override
  void initState() {
    pageController = PageController(initialPage: activeIndex);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: AppBarPadding(
        child: Consumer(builder: (context, watch, _) {
          final onboardingNotifier = watch(onboardingInfoProvider.notifier);
          final onboardingInfo = watch(onboardingInfoProvider);

          return Column(
            children: [
              StepCounterAppBar(
                activeIndex: activeIndex + 1,
                onBackPressed: () => pageController.previousPage(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                stepsNumber: 3,
              ),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                  children: [
                    GenderWidget(
                      initialData: onboardingInfo.gender,
                      onChanged: (g) {
                        onboardingNotifier.gender = g;
                      },
                    ),
                    AgeWidget(
                      initialData: DateTime.fromMillisecondsSinceEpoch(
                        onboardingInfo.age!,
                      ),
                      onChanged: (a) {
                        onboardingNotifier.age = a.millisecondsSinceEpoch;
                      },
                    ),
                    CountryWidget(
                      initialData: onboardingInfo.country,
                      onChanged: (c) {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: CtaButton(
                  onPressed: () {
                    if (pageController.page == 0) {
                      if (onboardingInfo.gender != null) nextPage();
                    } else {
                      nextPage();
                    }
                  },
                  text: 'NEXT',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void nextPage() => pageController.nextPage(
      duration: Duration(milliseconds: 250), curve: Curves.easeOut);

  void prevoiusPage() => pageController.previousPage(
      duration: Duration(milliseconds: 250), curve: Curves.easeOut);
}
