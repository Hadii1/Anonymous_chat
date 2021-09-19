import 'dart:math';

import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/material.dart';

class NameGenerator extends StatefulWidget {
  final Function(String) onChanged;

  const NameGenerator({
    required this.onChanged,
  });

  @override
  _NameGeneratorState createState() => _NameGeneratorState();
}

class _NameGeneratorState extends State<NameGenerator> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      rewindName();
    });
    super.initState();
  }

  String currentColor = '';
  String currentAnimal = '';
  int currentNumber = -1;

  String get name => '$currentColor$currentAnimal$currentNumber';

  void rewindName() async {
    currentNumber = -1;
    setState(() {});

    await Future.delayed(Duration(seconds: 1));
    currentColor = _kcolors[Random().nextInt(_kcolors.length - 1)];
    currentAnimal = _kanimals[Random().nextInt(_kcolors.length - 1)];
    currentNumber = Random().nextInt(999);
    widget.onChanged(name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTheming.of(context).style;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: KeyboardHider(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TitleText(title: 'USERNAME GENERATOR'),
            SizedBox(height: height * 0.2),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: currentNumber == -1
                  ? SpinKitHourGlass(
                      color: style.accentColor,
                      size: 55,
                    )
                  : SizedBox(
                      height: 55,
                      child: Text(
                        name,
                        style: style.title2Style
                            .copyWith(color: style.accentColor),
                      ),
                    ),
            ),
            SizedBox(
              height: 24,
            ),
            Fader(
              duration: Duration(milliseconds: 800),
              child: TextButton(
                onPressed: rewindName,
                style: ButtonStyle(splashFactory: NoSplash.splashFactory),
                child: Text(
                  'REWIND',
                  style: style.bodyText.copyWith(
                    color: style.borderColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

const List<String> _kanimals = [
  'Alligator',
  'Anteater',
  'Armadillo',
  'Auroch',
  'Axolotl',
  'Badger',
  'Bat',
  'Bear',
  'Beaver',
  'Buffalo',
  'Camel',
  'Capybara',
  'Chameleon',
  'Cheetah',
  'Chinchilla',
  'Chipmunk',
  'Chupacabra',
  'Cormorant',
  'Coyote',
  'Crow',
  'Dingo',
  'Dinosaur',
  'Dog',
  'Dolphin',
  'Duck',
  'Elephant',
  'Ferret',
  'Fox',
  'Frog',
  'Giraffe',
  'Gopher',
  'Grizzly',
  'Hedgehog',
  'Hippo',
  'Hyena',
  'Ibex',
  'Ifrit',
  'Iguana',
  'Jackal',
  'Kangaroo',
  'Koala',
  'Kraken',
  'Lemur',
  'Leopard',
  'Liger',
  'Lion',
  'Llama',
  'Loris',
  'Manatee',
  'Mink',
  'Monkey',
  'Moose',
  'Narwhal',
  'Orangutan',
  'Otter',
  'Panda',
  'Penguin',
  'Platypus',
  'Pumpkin',
  'Python',
  'Quagga',
  'Rabbit',
  'Raccoon',
  'Rhino',
  'Sheep',
  'Shrew',
  'Skunk',
  'Squirrel',
  'Tiger',
  'Turtle',
  'Walrus',
  'Wolf',
  'Wolverine',
  'Wombat',
];
const List<String> _kcolors = [
  'White',
  'Yellow',
  'Blue',
  'Red',
  'Green',
  'Black',
  'Brown',
  'Azure',
  'Ivory',
  'Teal',
  'Silver',
  'Purple',
  'Gray',
  'Orange',
  'Maroon',
  'Charcoal',
  'Aquamarine',
  'Coral',
  'Fuchsia',
  'Wheat',
  'Lime',
  'Crimson',
  'Khaki',
  'Magenta',
  'Olden',
  'Plum',
  'Olive',
  'Cyan',
];
