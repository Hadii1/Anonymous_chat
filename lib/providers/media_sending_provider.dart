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

import 'dart:io';

import 'package:anonymous_chat/providers/errors_provider.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final mediaChoosingProvider =
    FutureProvider.autoDispose<List<File>>((ref) async {
  try {
    List<File> files = [];
    List<PickedFile>? a = await ImagePicker().getMultiImage();

    if (a == null || a.isEmpty) return [];

    for (PickedFile pf in a) {
      File file = File(pf.path);
      files.add(file);
    }
    return files;
  } on Exception catch (e, s) {
    if (e is PlatformException && e.code == 'multiple_request') {
      return [];
    } else {
      ref
          .read(errorsProvider.notifier)
          .submitError(exception: e, stackTrace: s);
      return [];
    }
  }
});
