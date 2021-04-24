// Copyright 2021 hadihammoud
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

import 'package:flutter/material.dart';

class ShadedContainer extends StatelessWidget {
  const ShadedContainer({
    required this.child,
    required this.stops,
    this.height,
    this.width,
    this.isForground = false,
  });
  final Widget child;
  final double? width;
  final double? height;
  final bool isForground;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return !isForground
        ? Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: stops,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
            child: child,
          )
        : Container(
            width: width,
            height: height,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: stops,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
            child: child,
          );
  }
}
