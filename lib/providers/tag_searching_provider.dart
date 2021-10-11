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

import 'dart:async';
import 'dart:io';

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/interfaces/search_service_interface.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

enum TagScreenState {
  loadingTags,
  addingNewTag,
  showingSuggestedTags,
  idle,
}

final suggestedTagsProvider = ChangeNotifierProvider.autoDispose((ref) {
  return TagSuggestionsNotifier(
    ref.read,
    ref.read(errorsStateProvider.notifier),
  );
});

class TagSuggestionsNotifier extends ChangeNotifier {
  TagSuggestionsNotifier(
    this.read,
    this._errorNotifier,
  );

  final db = IDatabase.onlineDb;
  final storage = ILocalPrefs.storage;
  final searchService = ISearchService.searchService;

  final ErrorsNotifier _errorNotifier;
  final Reader read;

  List<Tag> suggestedTags = [];

  Tag? newTagToAdd;
  TagScreenState screenState = TagScreenState.idle;

  set searchedTag(String label) {
    suggestedTags = [];
    notifyListeners();

    if (label.isEmpty) {
      screenState = TagScreenState.idle;
      newTagToAdd = null;
      suggestedTags = [];

      notifyListeners();
    } else {
      _getSuggestedTags(label).then((List<Tag> suggestions) {
        screenState = TagScreenState.showingSuggestedTags;
        suggestedTags = suggestions;
        notifyListeners();
      });
    }
  }

  void onExistingTagPressed(
      {required Tag tag, required bool selected}) async {
    screenState = TagScreenState.idle;
    suggestedTags = [];
    notifyListeners();

    selected
        ? read(userTagsProvider.notifier).activateTag(tag)
        : read(userTagsProvider.notifier).deactivateTag(tag);
  }

  void onTagAdditionPressed() async {
    try {
      screenState = TagScreenState.addingNewTag;
      suggestedTags = [];

      notifyListeners();

      read(userTagsProvider.notifier).addNewTag(newTagToAdd!);

      screenState = TagScreenState.idle;
      newTagToAdd = null;

      notifyListeners();
    } on Exception catch (e, _) {
      _errorNotifier.set(
        e is SocketException
            ? 'Bad internet connection. Try again.'
            : 'Something went wrong. Try agian.',
      );

      screenState = TagScreenState.idle;
      notifyListeners();
    }
  }

  Future<List<Tag>> _getSuggestedTags(String label) async {
    try {
      if (label.isEmpty) return [];
      List<Tag> suggestedTags = [];
      screenState = TagScreenState.loadingTags;

      // get suggested tags data
      List<Map<String, dynamic>> algoliaData =
          await retry(f: () => searchService.getTagSuggestions(label: label));

      List<Map<String, dynamic>> data = await retry(
          f: () => db.getTagsById(
                ids: algoliaData
                    .map((Map<String, dynamic> e) => e['id'] as String)
                    .toList(),
              ));

      suggestedTags = data.map((e) => Tag.fromMap(e)).toList();

      // Remove already exisiting active tags
      List selectedTags =
          read(userTagsProvider)!.where((t) => t.isActive == true).toList();
      suggestedTags.removeWhere((element) => selectedTags.contains(element));

      // If the label isn't present in any of the suggested tags
      // allow adding it as a new tag
      if (!suggestedTags
          .map((e) => e.label.toLowerCase().trim())
          .contains(label.toLowerCase().trim())) {
        newTagToAdd = Tag(
          id: generateUid(),
          label: label,
        );
      }
      notifyListeners();

      return suggestedTags;
    } on Exception catch (e, _) {
      _errorNotifier.set(
        e is SocketException
            ? 'Bad internet connection. Try again.'
            : 'Something went wrong. Try agian.',
      );

      screenState = TagScreenState.idle;
      notifyListeners();
      return [];
    }
  }
}
