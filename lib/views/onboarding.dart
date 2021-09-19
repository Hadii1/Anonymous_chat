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

import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/views/name_generator_screen.dart';
import 'package:anonymous_chat/widgets/age.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/gender.dart';
import 'package:anonymous_chat/widgets/shaded_container.dart';
import 'package:anonymous_chat/widgets/step_counter_bar.dart';
import 'package:anonymous_chat/widgets/top_padding.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingInfo {
  factory OnboardingInfo.defaultValue() => OnboardingInfo(
        gender: '',
        nickname: '',
        age: 867618000000,
      );

  String? gender;
  String nickname;
  int? age;

  OnboardingInfo({
    this.gender,
    this.age,
    this.nickname = '',
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

  set nickname(String nickname) {
    state.nickname = nickname;
    state = state;
  }

  set age(int age) {
    state.age = age;
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

          return Stack(
            children: [
              Column(
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
                      physics: NeverScrollableScrollPhysics(),
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
                        NameGenerator(
                          onChanged: (n) => onboardingNotifier.nickname = n,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ShadedContainer(
                  stops: [0.1, 0.4],
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36, top: 48),
                    child: CtaButton(
                      onPressed: () async {
                        if (pageController.page == 0) {
                          if (onboardingInfo.gender != null &&
                              onboardingInfo.gender!.isNotEmpty) nextPage();
                        } else if (pageController.page == 2) {
                          bool success = await context
                              .refresh(userInfoSavingProvider(onboardingInfo));
                          if (success)
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => Home()),
                            );
                        } else {
                          nextPage();
                        }
                      },
                      text: 'NEXT',
                    ),
                  ),
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

final userInfoSavingProvider =
    FutureProvider.family.autoDispose<bool, OnboardingInfo>(
  (ref, info) async {
    IDatabase db = IDatabase.databseService;
    IAuth auth = IAuth.auth;

    Map<String, dynamic> userData = await db.getUserData(id: auth.getId()!)!;
    LocalUser currentUser = LocalUser.fromMap(userData);
    try {
      ref.read(loadingProvider.notifier).loading = true;
      await retry(
        f: () async => await db.saveUserData(
          user: LocalUser(
            id: currentUser.id,
            phoneNumber: currentUser.phoneNumber,
            dob: info.age!,
            gender: info.gender!,
            nickname: info.nickname,
          ),
        ),
      );
      return true;
    } on Exception catch (_) {
      ref
          .read(errorsStateProvider.notifier)
          .set('Something went wrong. Try again please');
      return false;
    } finally {
      ref.read(loadingProvider.notifier).loading = false;
    }
  },
);
