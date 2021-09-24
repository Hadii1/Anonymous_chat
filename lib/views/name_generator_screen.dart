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
  int currentNumber = 0;

  String get name => '$currentColor$currentAnimal$currentNumber';

  void rewindName() async {
    if (currentNumber == -1) return;
    currentNumber = -1;
    setState(() {});

    await Future.delayed(Duration(seconds: 1));
    currentColor = _kcolors[Random().nextInt(_kcolors.length - 1)];
    currentAnimal = _knames[Random().nextInt(_knames.length - 1)];
    currentNumber = Random().nextInt(99);
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
              child: currentNumber <=0
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

List<String> _kcolors = [
  'Red',
  'Orange',
  'Yellow',
  'Green',
  'Blue',
  'Indigo',
  'Violet',
  'Purple',
  'Black',
  'Grey',
  'Cadet',
  'Cyan',
  'Turquoise',
  'Azure',
  'Teal',
  'Brown',
  'Beige',
  'Chocolate',
  'Peru',
  'Tan',
  'Sienna',
  'Copper',
  'Olive',
  'Lime',
  'Coral',
  'Bisque',
  'Lavender',
  'Magenta',
  'Fuchsia',
  'Maroon',
  'Orchid',
  'Plum',
  'Purple',
  'White',
  'Ivory',
  'Linen',
  'Snow',
  'Quartz',
  'Conrsilk',
  'Gold',
  'Mocsasin',
  'Brass',
  'Bronze',
  'Silver',
];

List<String> _knames = [
  'Apollo',
  'Saros',
  'Phoenix',
  'Cosmos',
  'Ceilo',
  'Comet',
  'Meteor',
  'Phoebus',
  'Sky',
  'Starr',
  'Zenith',
  'Vulcan',
  'Jupiter',
  'Mercury',
  'Aerglo',
  'Pluto',
  'Janus',
  'Mars',
  'Oberon',
  'Jericho',
  'Holmes',
  'Neptune',
  'Aelius',
  'Aku',
  'Aibek',
  'Astennu',
  'Aten',
  'Arche',
  'Badar',
  'Badru',
  'Blaze',
  'Chan',
  'Cupid',
  'Deimos',
  'Donati',
  'Eos',
  'Hang',
  'Hesperus',
  'Hilal',
  'Iah',
  'Ilkay',
  'Io',
  'Kale',
  'Koray',
  'Kuiper',
  'Mahruk',
  'Maramma',
  'Mayank',
  'Meztli',
  'Muraco',
  'Nanna',
  'Neil',
  'Pallas',
  'Proteus',
  'Pulan',
  'Purnama',
  'Tamar',
  'Saturn',
  'Sol',
  'Themis',
  'Thule',
  'Titan',
  'Triton',
  'Orion',
  'Aries',
  'Atlas',
  'Perseus',
  'Leo',
  'Archer',
  'Sirius',
  'Castor',
  'Columba',
  'Hunter',
  'Nash',
  'Rigel',
  'Solar',
  'Taurus',
  'Hercules',
  'Alioth',
  'Aster',
  'Astrophel',
  'Altair',
  'Danica',
  'Draco',
  'Elio',
  'Hamal',
  'Hoku',
  'Izar',
  'Lintang',
  'Namid',
  'Pollux',
  'Rasalas',
  'Regulus',
  'Samson',
  'Wolf',
  'Galexia',
  'Andromeda',
  'Ophelia',
  'Titania',
  'Portia',
  'Venus',
  'Pandora',
  'Phoebe',
  'Halley',
  'Astrid',
  'Miranda',
  'Aurora',
  'Luna',
  'Calypso',
  'Cordelia',
  'Callisto',
  'Cressida',
  'Aina',
  'Alcmene',
  'Amaris',
  'Arianrhod',
  'Arpina',
  'Aylin',
  'Aysu',
  'Aysun',
  'Belinda',
  'Bellatrix',
  'Carina',
  'Cassini',
  'Charon',
  'Crescent',
  'Dione',
  'Eris',
  'Flora',
  'Gaia',
  'Galatea',
  'Hoshi',
  'Indu',
  'Jaci',
  'Kamaria',
  'Leda',
  'Mahdokht',
  'Mahtab',
  'Nevaeh',
  'Nokomis',
  'Pensri',
  'Rhea',
  'Thebe',
  'Rosalind',
  'Soleil',
  'Solstrice',
  'Solveig',
  'Thalassa',
  'Vesta',
  'Zelenia',
  'Cassiopeia',
  'Lyra',
  'Vega',
  'Libra',
  'Nova',
  'Adhara',
  'Alcyone',
  'Alpha',
  'Amalthea',
  'Aquarius',
  'Ascella',
  'Astra',
  'Capella',
  'Celestia',
  'Electra',
  'Esther',
  'Etoile',
  'Europa',
  'Gomeisa',
  'Juno',
  'Maia',
  'Nashira',
  'Norma',
  'Polaris',
  'Stella',
  'Starling',
  'Zaniah',
  'Caesar'
];
