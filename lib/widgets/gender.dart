import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Gender {
  static const String MALE = 'Male';
  static const String FEMALE = 'Female';
}

class GenderWidget extends StatefulWidget {
  const GenderWidget({
    required this.onChanged,
    this.initialData,
  });
  final Function(String) onChanged;
  final String? initialData;

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  String? _selectedGender;

  @override
  void initState() {
    _selectedGender = widget.initialData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AnimationConfiguration.toStaggeredList(
          childAnimationBuilder: (w) {
            return SlideAnimation(
              duration: Duration(milliseconds: 550),
              horizontalOffset: -200,
              child: FadeInAnimation(
                child: w,
                duration: Duration(milliseconds: 400),
              ),
            );
          },
          children: [
            TitleText(
              title: 'MALE OR FEMALE?',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 58, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // MALE BOX

                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.MALE;
                          widget.onChanged(_selectedGender!);
                        });
                      },
                      child: AnimatedContainer(
                        height: 195,
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: _selectedGender == Gender.MALE ? 0.7 : 0.35,
                            color: _selectedGender == Gender.MALE
                                ? style.accentColor
                                : style.borderColor,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/man.png',
                            height: 93,
                            color: () {
                              if (_selectedGender == Gender.MALE)
                                return style.accentColor;
                              else if (_selectedGender == null)
                                return Colors.white;
                              else
                                return Color(0xff5D5D5D);
                            }(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // FEMALE BOX

                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGender = Gender.FEMALE;
                          widget.onChanged(_selectedGender!);
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 195,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width:
                                _selectedGender == Gender.FEMALE ? 0.7 : 0.35,
                            color: _selectedGender == Gender.FEMALE
                                ? style.accentColor
                                : style.borderColor,
                          ),
                        ),
                        child: Center(
                          child: Image.asset('assets/icons/woman.png',
                              height: 93, color: () {
                            if (_selectedGender == Gender.FEMALE)
                              return style.accentColor;
                            else if (_selectedGender == null)
                              return Colors.white;
                            else
                              return Color(0xff5D5D5D);
                          }()),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
