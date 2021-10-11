// Copyright 2021 Hadi Hammoud
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

import 'dart:math';

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/cta_button.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';
import 'package:anonymous_chat/widgets/shaded_container.dart';
import 'package:anonymous_chat/widgets/top_padding.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NameScreen extends StatefulWidget {
  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  String? currentName;
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: AppBarPadding(
        child: Consumer(
          builder: (context, watch, _) {
            return Column(
              children: [
                Expanded(
                  child: NameGenerator(
                    onChanged: (n) => currentName = n,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ShadedContainer(
                    stops: [0.1, 0.4],
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36, top: 48),
                      child: CtaButton(
                        onPressed: () async {
                          if (currentName == null) return;
                          bool success = await context.refresh(
                            userInfoSavingProvider(currentName!),
                          );
                          if (success)
                            Navigator.of(context).push(
                              CupertinoPageRoute(builder: (_) => Home()),
                            );
                        },
                        text: 'NEXT',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
              child: currentNumber <= 0
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

final userInfoSavingProvider = FutureProvider.family.autoDispose<bool, String>(
  (ref, name) async {
    IDatabase db = IDatabase.onlineDb;
    ILocalPrefs prefs = ILocalPrefs.storage;
    LocalUser user = ref.read(userAuthEventsProvider)!;

    try {
      ref.read(loadingProvider.notifier).loading = true;
      await retry(f: () async {
        await db.saveUserData(
          user: user.copyWith(nickname: user),
        );
        await prefs.setUser(user.copyWith(nickname: user));
      });
      return true;
    } on Exception catch (_) {
      ref
          .read(errorsStateProvider.notifier)
          .set('Something went wrong. Try again please');
      return false;
    } finally {
      ref.read(loadingProvider.notifier).loading = false;
    }
  },
);

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
