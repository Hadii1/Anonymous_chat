import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/suggestions_provider.dart';
import 'package:anonymous_chat/providers/tag_searching_provider.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
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
import 'package:fluttericon/linecons_icons.dart';
import 'package:tuple/tuple.dart';

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
            final tagsNotifier = watch(suggestedTagsProvider);

            return ListView(
              children: [
                Container(
                  color: style.backgroundColor,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: SearchField(
                        hint: 'Search or add new tags to match up',
                        onChanged: (value) => tagsNotifier.searchedTag = value,
                      ),
                    ),
                  ),
                ),
                _TagsSearchResponse(),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: tagsNotifier.screenState == null
                      ? _SuggestedContacts()
                      : SizedBox.shrink(),
                ),
              ],
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
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(
      builder: (context, watch, child) {
        final userTags = watch(userTagsProvider(LocalStorage().user!.id).state);
        final tagsNotifier = watch(suggestedTagsProvider);
        return AnimatedSize(
          vsync: this,
          duration: Duration(milliseconds: 260),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: () {
              switch (tagsNotifier.screenState) {
                case null:
                  return TagsRow(
                    tags: userTags,
                    onSelected: (Tag tag, bool selected) {
                      context.read(suggestedTagsProvider).onExistingTagPressed(
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

                case TagScreenState.showingResults:
                  return Column(
                    children: [
                      tagsNotifier.newTagToAdd != null
                          ? _NewTagTile(
                              label: tagsNotifier.newTagToAdd!.label,
                              onAddedPressed: () => context
                                  .read(suggestedTagsProvider)
                                  .onTagAdditionPressed(),
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
    final style = InheritedAppTheme.of(context).style;
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
    final style = InheritedAppTheme.of(context).style;
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
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(
      builder: (context, watch, child) {
        final activeTags =
            watch(userTagsProvider(LocalStorage().user!.id).state)
                .where((Tag tag) => tag.isActive);
        final allTags = watch(userTagsProvider(LocalStorage().user!.id).state);
        return AnimatedSize(
          vsync: this,
          curve: Curves.easeOutCubic,
          duration: Duration(milliseconds: 350),
          child: watch(suggestedContactsProvider).when(
            data: (List<Tuple2<User, List<Tag>>>? data) {
              return data == null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: SpinKitThreeBounce(
                        size: 25,
                        duration: Duration(milliseconds: 800),
                        color: style.loadingBarColor,
                      ),
                    )
                  : data.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                            ],
                          ),
                        )
                      : Fader(
                          duration: Duration(milliseconds: 300),
                          child: Column(
                            children: List.generate(
                              data.length,
                              (index) => SuggestedContact(
                                data: data[index],
                              ),
                            ),
                          ),
                        );
            },
            loading: () => Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: SpinKitThreeBounce(
                size: 25,
                duration: Duration(milliseconds: 800),
                color: style.accentColor,
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
        );
      },
    );
  }
}
