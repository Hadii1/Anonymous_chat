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
//
//
import 'dart:async';

import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TagScreenState {
  loadingTags,
  showingResults,
  addingNewTag,
}

final suggestedTagsProvider = ChangeNotifierProvider.autoDispose((ref) {
  return TagSuggestionsNotifier(ref.read);
});

class TagSuggestionsNotifier extends ChangeNotifier {
  TagSuggestionsNotifier(
    this.read,
  ) {
    _errorNotifier = read(errorsProvider);
  }

  final FirestoreService firestore = FirestoreService();
  final LocalStorage storage = LocalStorage();
  final AlgoliaSearch algolia = AlgoliaSearch();
  final Reader read;

  late ErrorNotifier _errorNotifier;

  List<Tag> suggestedTags = [];

  Tag? newTagToAdd;
  TagScreenState? screenState;
  Timer? _debounceTimer;
  String? currentLabel;

  set searchedTag(String label) {
    if (label.isEmpty) {
      screenState = null;
      newTagToAdd = null;
      suggestedTags = [];
      currentLabel = null;

      notifyListeners();

      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();
      }

      return;
    }

    // To avoid unnessecary rebuilds
    if (screenState != TagScreenState.loadingTags ||
        currentLabel != null ||
        suggestedTags.isNotEmpty) {
      screenState = TagScreenState.loadingTags;
      newTagToAdd = null;
      suggestedTags = [];
      notifyListeners();
    }

    currentLabel = label;

    if (_debounceTimer == null) {
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        _getSuggestedTags();
      });
    } else {
      _debounceTimer!.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        _getSuggestedTags();
      });
    }
  }

  void onExistingTagPressed({required Tag tag, required bool selected}) async {
    try {
      screenState = null;
      currentLabel = null;
      suggestedTags = [];
      notifyListeners();

      if (selected) {
        await firestore.onUserActivatingTag(
            tag: tag.copyWith(isActive: selected), userId: storage.user!.id);
      } else {
        await firestore.onUserDiactivatingTag(
          tag: tag.copyWith(isActive: selected),
          userId: storage.user!.id,
        );
      }
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'on tag pressed in suggestions notifier',
      );
    }
    notifyListeners();
  }

  void onTagAdditionPressed() async {
    try {
      screenState = TagScreenState.addingNewTag;
      notifyListeners();

      suggestedTags = [];
      currentLabel = null;
      notifyListeners();

      await algolia.addSearchableTag(tag: newTagToAdd!);

      await firestore.addNewTag(
        tag: newTagToAdd!,
        userId: storage.user!.id,
      );

      screenState = null;
      newTagToAdd = null;

      notifyListeners();
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'Get suggested tags in suggestions notifier',
      );

      screenState = null;
      notifyListeners();
    }
  }

  void _getSuggestedTags() async {
    try {
      if (currentLabel == null || currentLabel!.isEmpty) return;

      screenState = TagScreenState.loadingTags;

      List<Map<String, dynamic>> algoliaData =
          await algolia.getTagSuggestions(label: currentLabel!);

      List<Map<String, dynamic>> data =
          await FirestoreService().getSuggestedTags(
        ids: algoliaData
            .map((Map<String, dynamic> e) => e['id'] as String)
            .toList(),
      );

      List selectedTags = read(userTagsProvider(storage.user!.id).state)
          .where((t) => t.isActive == true)
          .toList();

      suggestedTags = data.map((e) => Tag.fromMap(e)).toList();
      suggestedTags.removeWhere((element) => selectedTags.contains(element));

      // If tag is new allow adding it
      if (!suggestedTags
          .map((e) => e.label.toLowerCase())
          .contains(currentLabel!.toLowerCase())) {
        newTagToAdd = Tag(
          id: firestore.getTagReference(),
          isActive: true,
          label: currentLabel!,
        );
      }

      screenState = TagScreenState.showingResults;

      notifyListeners();
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'Get suggested tags in suggestions notifier',
      );
      screenState = null;
      notifyListeners();
    }
  }
}
