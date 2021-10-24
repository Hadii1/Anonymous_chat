import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    required this.children,
    required this.headers,
  }) : assert(headers.length == children.length);

  final List<Widget> children;
  final List<String> headers;

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  final PageController _pageController = PageController(initialPage: 0);

  int _activeChild = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final _activeLabelStyle = TextStyle(
    fontSize: 11.2,
    color: Colors.white,
    letterSpacing: 1,
  );

  final _unactiveLabelStyle = TextStyle(
    fontSize: 11.2,
    letterSpacing: 1,
    color: Color(0xff505C69),
  );

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            widget.headers.length,
            (index) {
              return InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeIn,
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: index == _activeChild
                          ? BorderSide(
                              width: 0.35,
                              color: style.accentColor,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    child: AnimatedDefaultTextStyle(
                      style: index == _activeChild
                          ? _activeLabelStyle
                          : _unactiveLabelStyle,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.headers[index].toUpperCase(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: PageView(
            physics: ClampingScrollPhysics(),
            onPageChanged: (page) {
              _activeChild = page;
              setState(() {});
            },
            children: widget.children
                .map(
                  (c) => KeepAlive(
                    child: c,
                  ),
                )
                .toList(),
            controller: _pageController,
          ),
        )
      ],
    );
  }
}

// Flutter intentionally unloads tabs that aren't visible to save memory.
// We force them to stay around by using the KeepAlive machinery.

class KeepAlive extends StatefulWidget {
  const KeepAlive({required this.child});
  final Widget child;

  @override
  _KeepAliveState createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin<KeepAlive> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
