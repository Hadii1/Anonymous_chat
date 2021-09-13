import 'package:anonymous_chat/utilities/constants.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AgeWidget extends StatefulWidget {
  const AgeWidget({
    required this.onChanged,
    required this.initialData,
  });
  final void Function(DateTime) onChanged;
  final DateTime initialData;

  @override
  _AgeWidgetState createState() => _AgeWidgetState();
}

class _AgeWidgetState extends State<AgeWidget> {
  late DateTime _birthDate;

  @override
  void initState() {
    _birthDate = widget.initialData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: AnimationConfiguration.toStaggeredList(
          childAnimationBuilder: (w) {
            return SlideAnimation(
              duration: Duration(milliseconds: 500),
              horizontalOffset: 200,
              child: FadeInAnimation(
                child: w,
                duration: Duration(milliseconds: 470),
              ),
            );
          },
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  title: 'DATE OF BIRTH',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 38, left: 24, right: 24),
                  child: SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: DayAndMonthSpinners(
                            initialDay: _birthDate.day,
                            initialMonth: _birthDate.month,
                            onChanged: (day, month) {
                              _birthDate =
                                  DateTime(_birthDate.year, month, day);
                              widget.onChanged(_birthDate);
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: YearSpinner<int>(
                            onYearChanged: (int year) {
                              _birthDate = DateTime(
                                year,
                                _birthDate.month,
                                _birthDate.day,
                              );
                              widget.onChanged(_birthDate);
                            },
                            initalValue: _birthDate.year,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class YearSpinner<T> extends StatefulWidget {
  YearSpinner({
    required this.onYearChanged,
    required this.initalValue,
  });
  final void Function(int) onYearChanged;
  final int initalValue;

  @override
  _YearSpinnerState createState() => _YearSpinnerState();
}

class _YearSpinnerState extends State<YearSpinner> {
  late PageController _pageController;
  late int _activeYear;

  @override
  void initState() {
    _activeYear = widget.initalValue - 1901;
    _pageController = PageController(
      viewportFraction: 0.27,
      initialPage: _activeYear,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 120,
      onPageChanged: (index) {
        HapticFeedback.lightImpact();
        setState(() {
          _activeYear = index;
          widget.onYearChanged(_activeYear + 1901);
        });
      },
      itemBuilder: (_, index) {
        return AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 50),
          style: TextStyle(
            fontSize: 38,
            color: index == _activeYear
                ? Colors.white
                : Colors.white.withOpacity(0.12),
            letterSpacing: 4,
          ),
          child: Text(
            '${index + 1901}',
            style: TextStyle(fontFamily: 'SourceSans'),
            textAlign: TextAlign.center,
          ),
        );
      },
      scrollDirection: Axis.vertical,
    );
  }
}

class DayAndMonthSpinners extends StatefulWidget {
  DayAndMonthSpinners({
    required this.initialDay,
    required this.initialMonth,
    required this.onChanged,
  });

  final int initialMonth;
  final int initialDay;

  final Function(int day, int month) onChanged;

  @override
  _DayAndMonthSpinnersState createState() => _DayAndMonthSpinnersState();
}

class _DayAndMonthSpinnersState extends State<DayAndMonthSpinners> {
  late PageController _dayController;
  late PageController _monthController;

  late int _activeMonth;
  late int _activeDay;

  int _numberOfDays = 30; // default month is june

  @override
  void initState() {
    _activeDay = widget.initialDay;
    _activeMonth = widget.initialMonth;

    _dayController = PageController(
      viewportFraction: 0.27,
      initialPage: _activeDay - 1,
    );

    _monthController = PageController(
      viewportFraction: 0.27,
      initialPage: _activeMonth - 1,
    );

    super.initState();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: PageView.builder(
            controller: _dayController,
            itemCount: _numberOfDays,
            onPageChanged: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _activeDay = index + 1;
                widget.onChanged(
                  _activeDay,
                  _activeMonth,
                );
              });
            },
            itemBuilder: (_, index) {
              return AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 50),
                style: TextStyle(
                  fontSize: 38,
                  color: index == _activeDay - 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.12),
                  letterSpacing: 4,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontFamily: 'SourceSans'),
                  textAlign: TextAlign.center,
                ),
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ),
        Flexible(
          flex: 2,
          child: PageView.builder(
            controller: _monthController,
            itemCount: 12,
            onPageChanged: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _activeMonth = index + 1;

                switch (_activeMonth) {
                  case 2:
                    _numberOfDays = 29;
                    break;
                  case 4:
                  case 6:
                  case 9:
                  case 11:
                    _numberOfDays = 30;
                    break;
                  default:
                    _numberOfDays = 31;
                    break;
                }

                if (_numberOfDays < _activeDay) {
                  _dayController.animateToPage(
                    _numberOfDays - 1,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                  _activeDay = _numberOfDays;
                }
                widget.onChanged(
                  _activeDay,
                  _activeMonth,
                );
              });
            },
            itemBuilder: (_, index) {
              return AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 50),
                style: TextStyle(
                  fontSize: 38,
                  color: index == _activeMonth - 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.12),
                  letterSpacing: 4,
                ),
                child: Text(
                  ConstantsUtil.MONTHS[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'SourceSans'),
                ),
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ),
      ],
    );
  }
}
