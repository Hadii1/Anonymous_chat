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

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: index == activeIndex
                      ? style.accentColor
                      : Colors.transparent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == activeIndex
                        ? style.accentColor
                        : Colors.white.withOpacity(0.14),
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
