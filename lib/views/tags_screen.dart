import 'dart:async';
import 'dart:io';

import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/suggestions_provider.dart';
import 'package:anonymous_chat/providers/tag_searching_provider.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';
import 'package:anonymous_chat/widgets/search_field.dart';
import 'package:anonymous_chat/widgets/suggestion_header.dart';
import 'package:anonymous_chat/widgets/tags_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttericon/linecons_icons.dart';

class TagsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;

    return Scaffold(
      backgroundColor: style.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: KeyboardHider(
        child: Consumer(
          builder: (context, watch, child) {
            AsyncValue<List<UserTag>> tagsData = watch(userTagsFuture);
            final tagsNotifier = watch(suggestedTagsProvider);

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: () {
                if (tagsData is AsyncLoading)
                  return LoadingWidget(
                    isLoading: true,
                  );

                if (tagsData is AsyncError) {
                  Future.delayed(Duration(seconds: 2)).then(
                    (value) => context.refresh(userTagsProvider),
                  );

                  return LoadingWidget(
                    isLoading: true,
                  );
                }
                return ListView(
                  children: [
                    Container(
                      color: style.backgroundColor,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: _TagsSearchField(
                            onChanged: (value) =>
                                tagsNotifier.searchedTag = value,
                          ),
                        ),
                      ),
                    ),
                    _TagsSearchResponse(),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 350),
                      child: tagsNotifier.screenState == TagScreenState.idle
                          ? _SuggestedContacts()
                          : SizedBox.shrink(),
                    ),
                  ],
                );
              }(),
            );
          },
        ),
      ),
    );
  }
}

class _TagsSearchResponse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TagsSearchResponseState();
}

class _TagsSearchResponseState extends State<_TagsSearchResponse>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Consumer(
      builder: (context, watch, child) {
        final List<UserTag> userTags = watch(userTagsProvider)!;
        final tagsNotifier = watch(suggestedTagsProvider);
        return AnimatedSize(
          duration: Duration(milliseconds: 260),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: () {
              switch (tagsNotifier.screenState) {
                case TagScreenState.idle:
                  return TagsRow(
                    tags: userTags,
                    onSelected: (Tag tag, bool selected) {
                      tagsNotifier.onExistingTagPressed(
                        tag: tag,
                        selected: selected,
                      );
                    },
                  );
                case TagScreenState.addingNewTag:
                  return Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: SpinKitDualRing(
                      size: 40,
                      color: style.accentColor,
                    ),
                  );

                case TagScreenState.loadingTags:
                  return Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: SpinKitDualRing(
                      size: 40,
                      color: style.accentColor,
                    ),
                  );

                case TagScreenState.showingSuggestedTags:
                  return Column(
                    children: [
                      tagsNotifier.newTagToAdd != null
                          ? _NewTagTile(
                              label: tagsNotifier.newTagToAdd!.label,
                              onAddedPressed: () =>
                                  tagsNotifier.onTagAdditionPressed(),
                            )
                          : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _SuggestedTagsList(
                          tags: tagsNotifier.suggestedTags,
                          onSelected: (Tag tag) => context
                              .read(suggestedTagsProvider)
                              .onExistingTagPressed(
                                tag: tag,
                                selected: true,
                              ),
                        ),
                      ),
                    ],
                  );
              }
            }(),
          ),
        );
      },
    );
  }
}

class _NewTagTile extends StatelessWidget {
  const _NewTagTile({
    required this.label,
    required this.onAddedPressed,
  });
  final String label;
  final Function() onAddedPressed;
  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Be the first to add this tag',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Material(
            color: Colors.black,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                width: 0.2,
                color: Colors.white,
              ),
            ),
            child: InkWell(
              onTap: () {
                onAddedPressed();
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: style.bodyText,
                    ),
                    InkResponse(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      radius: 10,
                      splashColor: style.accentColor,
                      onTap: () {
                        onAddedPressed();
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
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
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Divider(
            thickness: 0.15,
            color: style.borderColor,
            indent: MediaQuery.of(context).size.width * 0.15,
            endIndent: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(
            height: 16,
          ),
        ],
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
    final style = AppTheming.of(context).style;
    return tags.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Similar tags',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
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
                          child: InkWell(
                            splashColor: style.accentColor,
                            highlightColor: style.accentColor,
                            onTap: () {
                              onSelected(
                                tag,
                              );
                              FocusScope.of(context).unfocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    onTap: () {
                                      onSelected(
                                        tag,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class _SuggestedContacts extends StatefulWidget {
  @override
  __SuggestedContactsState createState() => __SuggestedContactsState();
}

class __SuggestedContactsState extends State<_SuggestedContacts>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24),
      child: Consumer(
        builder: (context, watch, child) {
          final List<UserTag> allTags = watch(userTagsProvider)!;
          final List<UserTag> activeTags =
              allTags.where((UserTag userTag) => userTag.isActive).toList();

          return watch(suggestedContactsProvider).when(
            data: (List<Contact>? data) {
              return Fader(
                duration: Duration(milliseconds: 300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data == null
                      ? [
                          SpinKitThreeBounce(
                            size: 25,
                            duration: Duration(milliseconds: 800),
                            color: style.loadingBarColor,
                          )
                        ]
                      : data.isEmpty
                          ? [
                              SizedBox(
                                height: 50,
                              ),
                              Icon(
                                Linecons.search,
                                color: style.accentColor,
                                size: 50,
                              ),
                              SizedBox(height: 24),
                              Text(
                                allTags.isEmpty
                                    ? 'Search and activate \nnew tags to match up with\nother contacts.'
                                    : activeTags.isEmpty
                                        ? 'No current active tags.'
                                        : 'No contacts are sharing\nyour active tags.\nTry changing or adding\nnew tags.',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ]
                          : List.generate(
                              data.length,
                              (index) => SuggestedContact(
                                contact: data[index],
                              ),
                            ),
                ),
              );
            },
            loading: () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: SpinKitThreeBounce(
                    size: 25,
                    duration: Duration(milliseconds: 800),
                    color: style.accentColor,
                  ),
                ),
              ],
            ),
            error: (e, s) {
              context.read(errorsStateProvider.notifier).set(
                  e is SocketException
                      ? 'Bad internet connection'
                      : 'An Error occured');

              Future.delayed(Duration(seconds: 2))
                  .then((_) => context.refresh(suggestedContactsProvider));

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
          );
        },
      ),
    );
  }
}

class _TagsSearchField extends StatefulWidget {
  final Function(String) onChanged;

  const _TagsSearchField({
    required this.onChanged,
  });

  @override
  _TagsSearchFieldState createState() => _TagsSearchFieldState();
}

class _TagsSearchFieldState extends State<_TagsSearchField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchField(
      hint: 'Search or add new tags to match up',
      onChanged: (v) {
        cancelTimer();
        if (v.isEmpty) {
          widget.onChanged('');
        } else {
          _debounceTimer = Timer(Duration(milliseconds: 400), () {
            widget.onChanged(v);
          });
        }
      },
    );
  }

  void cancelTimer() {
    if (_debounceTimer != null && _debounceTimer!.isActive)
      _debounceTimer!.cancel();
  }
}
