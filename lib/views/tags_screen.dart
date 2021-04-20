import 'dart:async';

import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/providers/suggestions_provider.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/search_field.dart';
import 'package:anonymous_chat/widgets/suggestion_header.dart';
import 'package:anonymous_chat/widgets/tags_row.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tuple/tuple.dart';

final suggestedTagsProvider = ChangeNotifierProvider.autoDispose((ref) {
  return TagSuggestionsNotifier(ref.read);
});

class TagSuggestionsNotifier extends ChangeNotifier {
  late ErrorNotifier _errorNotifier;
  late LoadingNotifer _loadingNotifier;
  final Reader read;

  TagSuggestionsNotifier(
    this.read,
  ) {
    _errorNotifier = read(errorsProvider);
    _loadingNotifier = read(loadingProvider);
  }

  final FirestoreService firestore = FirestoreService();
  final LocalStorage storage = LocalStorage();
  final AlgoliaSearch algolia = AlgoliaSearch();

  List<Tag> suggestedTags = [];

  bool loadingTags = false;

  Timer? _debounceTimer;
  String? currentLabel;

  set searchedTag(String label) {
    if (label.isEmpty) {
      loadingTags = false;
      suggestedTags = [];
      notifyListeners();
      if (_debounceTimer != null && _debounceTimer!.isActive) {
        _debounceTimer!.cancel();

        return;
      }
    }

    loadingTags = true;
    suggestedTags = [];
    currentLabel = label;
    notifyListeners();

    if (_debounceTimer == null) {
      _debounceTimer = Timer(Duration(seconds: 1), () {
        _getSuggestedTags(label);
      });
    } else {
      _debounceTimer!.cancel();
      _debounceTimer = Timer(Duration(seconds: 1), () {
        _getSuggestedTags(label);
      });
    }
  }

  void onTagPressed({required Tag tag, required bool selected}) async {
    try {
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

      notifyListeners();
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'on tag pressed in suggestions notifier',
      );

      notifyListeners();
    }
    notifyListeners();
  }

  void onTagAdditionPressed() async {
    try {
      _loadingNotifier.isLoading = true;

      String id = firestore.getTagReference();

      Tag tag = Tag(
        id: id,
        label: currentLabel!,
        isActive: true,
      );

      suggestedTags = [];
      currentLabel = null;
      notifyListeners();

      await algolia.addSearchableTag(tag: tag);

      await firestore.addNewTag(
        tag: tag,
        userId: storage.user!.id,
      );

      loadingTags = false;
      _loadingNotifier.isLoading = false;
      notifyListeners();
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'Get suggested tags in suggestions notifier',
      );
      loadingTags = false;
      _loadingNotifier.isLoading = false;
      notifyListeners();
    }
  }

  void _getSuggestedTags(String label) async {
    try {
      if (label.isEmpty) return;
      loadingTags = true;

      List<Map<String, dynamic>> algoliaData =
          await algolia.getTagSuggestions(label: label);

      List<Map<String, dynamic>> data =
          await FirestoreService().getSuggestedTags(
        ids: algoliaData
            .map((Map<String, dynamic> e) => e['id'] as String)
            .toList(),
      );

      List selectedTags = read(tagsProvider(storage.user!.id).state)
          .where((t) => t.isActive == true)
          .toList();
      suggestedTags = data.map((e) => Tag.fromMap(e)).toList();
      suggestedTags.removeWhere((element) => selectedTags.contains(element));

      loadingTags = false;

      notifyListeners();
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'Get suggested tags in suggestions notifier',
      );
      loadingTags = false;
      notifyListeners();
    }
  }
}

class TagsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;

    return Scaffold(
      backgroundColor: style.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: KeyboardHider(
        child: Consumer(
          builder: (context, watch, child) {
            final userTags = watch(tagsProvider(LocalStorage().user!.id).state);
            final tagsNotifier = watch(suggestedTagsProvider);
            final suggestedContacts = watch(suggestedContactsProvider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: style.backgroundColor,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: SearchField(
                        hint: 'Search for tags to match up',
                        loading: tagsNotifier.loadingTags,
                        showPlusIcon: tagsNotifier.currentLabel != null &&
                            tagsNotifier.currentLabel!.isNotEmpty &&
                            !tagsNotifier.suggestedTags
                                .map((e) => e.label)
                                .contains(tagsNotifier.currentLabel),
                        onChanged: (value) => tagsNotifier.searchedTag = value,
                        onPlusPressed: () {
                          FocusScope.of(context).unfocus();
                          context
                              .read(suggestedTagsProvider)
                              .onTagAdditionPressed();
                        },
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: tagsNotifier.suggestedTags.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _SuggestedTagsList(
                            tags: tagsNotifier.suggestedTags,
                            onSelected: (Tag tag) => context
                                .read(suggestedTagsProvider)
                                .onTagPressed(
                                  tag: tag,
                                  selected: true,
                                ),
                          ),
                        )
                      : CustomSlide(
                          startOffset: Offset(0, 1),
                          endOffset: Offset.zero,
                          duration: Duration(milliseconds: 250),
                          child: TagsRow(
                            tags: userTags,
                            onSelected: (Tag tag, bool selected) {
                              context.read(suggestedTagsProvider).onTagPressed(
                                    tag: tag,
                                    selected: selected,
                                  );
                            },
                          ),
                        ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 150),
                    child: suggestedContacts.when(
                      data: (List<Tuple2<User, List<Tag>>> data) {
                        return data.isEmpty
                            ? SizedBox.shrink()
                            : AnimationLimiter(
                                child: ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder: (c, index) {
                                    return AnimationConfiguration.staggeredList(
                                      duration: Duration(milliseconds: 300),
                                      position: index,
                                      child: SlideAnimation(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 24,
                                            top: index == 0 ? 0 : 16,
                                          ),
                                          child: SuggestedContact(
                                            data: data[index],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                      },
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: SpinKitThreeBounce(
                            size: 30,
                            duration: Duration(milliseconds: 800),
                            color: style.backgroundContrastColor,
                          ),
                        ),
                      ),
                      error: (e, s) {
                        context.read(errorsProvider).setError(
                              exception: e,
                              stackTrace: s,
                              hint:
                                  'Error in watching suggested contacts provider. Retrying.',
                            );

                        context.refresh(suggestedContactsProvider);
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: SpinKitThreeBounce(
                              size: 25,
                              color: style.backgroundContrastColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SuggestedTagsList extends StatelessWidget {
  final List<Tag> tags;
  final Function(Tag) onSelected;

  _SuggestedTagsList({
    required this.tags,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final style = InheritedAppTheme.of(context).style;
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            childAnimationBuilder: (w) {
              return SlideAnimation(
                child: w,
                verticalOffset: -30,
                duration: Duration(milliseconds: 250),
              );
            },
            children: List.generate(
              tags.length,
              (index) {
                Tag tag = tags[index];
                return Material(
                  color: Colors.black,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      width: 0.2,
                      color: Colors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tag.label,
                          style: style.bodyText,
                        ),
                        InkResponse(
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          radius: 10,
                          splashColor: style.accentColor,
                          onTap: () => onSelected(
                            tag,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tag.isActive
                                  ? style.accentColor
                                  : Colors.black,
                              border: Border.all(
                                color: style.accentColor,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
