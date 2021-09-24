import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

import 'package:flutter/material.dart';

class TagsRow extends StatelessWidget {
  final List<UserTag> tags;
  final String? title;
  final void Function(Tag, bool) onSelected;

  const TagsRow({
    this.title,
    required this.tags,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == null
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  title!,
                  style: style.title2Style,
                ),
              ),
        SingleChildScrollView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              tags.length,
              (index) => _Chip(
                onSelected: onSelected,
                isSelected: tags[index].isActive,
                tag: tags[index].tag,
                isFirstElement: index == 0,
                isLastElement: index == tags.length - 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatefulWidget {
  final Function(Tag, bool) onSelected;
  final bool isSelected;
  final Tag tag;
  final bool isFirstElement;
  final bool isLastElement;

  const _Chip({
    required this.onSelected,
    required this.isSelected,
    required this.tag,
    required this.isFirstElement,
    required this.isLastElement,
  });

  @override
  __ChipState createState() => __ChipState();
}

class __ChipState extends State<_Chip> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected;
  }

  @override
  void didUpdateWidget(_Chip oldWidget) {
    if (widget.isSelected != oldWidget.isSelected)
      setState(() {
        _selected = widget.isSelected;
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Padding(
      padding: EdgeInsets.only(
        left: widget.isFirstElement ? 24 : 0,
        right: widget.isLastElement ? 24 : 0,
      ),
      child: Padding(
        padding: widget.isFirstElement
            ? const EdgeInsets.only(right: 8.0, top: 8)
            : widget.isLastElement
                ? const EdgeInsets.only(left: 8.0, top: 8)
                : const EdgeInsets.all(8.0),
        child: ChoiceChip(
          label: AnimatedDefaultTextStyle(
            style: _selected
                ? style.bodyText.copyWith(color: style.accentColor)
                : style.bodyText,
            duration: Duration(milliseconds: 250),
            child: Text(
              widget.tag.label,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: style.backgroundColor,
          side: BorderSide(
            width: 0.1,
            color: _selected ? style.accentColor : style.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          selectedColor: style.backgroundColor,
          onSelected: (selected) {
            setState(() {
              widget.onSelected(widget.tag, selected);
              _selected = selected;
            });
          },
          selected: _selected,
        ),
      ),
    );
  }
}
