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

// class AllRetriesFailException implements Exception {}

import 'dart:math';

Future<T?> retry<T>({
  required Future<T> Function() f,
  Function({Exception e, StackTrace s})? onFirstThrow,
  Duration duration = const Duration(milliseconds: 400),
  Duration timeout = const Duration(minutes: 2),
  bool shouldRethrow = true,
  bool sendExceptionToSentry = true,
  int maxAttempts = 3,
  double delayFactor = 0.25,
}) async {
  int attempts = 0;

  while (true) {
    try {
      return await f().timeout(timeout);
    } on Exception catch (e, s) {
      if (attempts == maxAttempts) {
        print('\n \n \nMax attempts reached\n \n \n ');
        if (shouldRethrow)
          rethrow;
        else
          return null;
      }

      if (attempts == 0) {
        print(e);
        print(s);
        if (onFirstThrow != null) onFirstThrow(e: e, s: s);
        // if (sendExceptionToSentry) Sentry.captureException(e, stackTrace: s);
      }

      await Future.delayed(duration + (duration * attempts * delayFactor));

      attempts++;
    }
  }
}

String generateUid() {
  const CHARS =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  String id = '';

  for (int i = 0; i < 28; i++) {
    id += CHARS[Random().nextInt(28)];
  }
  return id;
}

extension CapitalizeFirstLetter on String {
  String capitalizeFirst() {
    return this.length == 1
        ? this.toUpperCase()
        : this.substring(0, 1).toUpperCase() + this.substring(1);
  }
}
