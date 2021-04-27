import 'dart:math';

import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kloadingTime = Duration(seconds: 2);
final nameGeneratorProvider = ChangeNotifierProvider.autoDispose(
  (ref) => NameGeneratorNotifier(
    ref.read(errorsProvider),
  ),
);

class NameGeneratorNotifier extends ChangeNotifier {
  final ErrorNotifier _errorNotifier;

  NameGeneratorNotifier(this._errorNotifier) {
    Future.delayed(_kloadingTime).then((value) {
      loading = false;
      notifyListeners();
    });
  }

  String color = _kcolors[Random().nextInt(_kcolors.length - 1)];
  String animal = _kanimals[Random().nextInt(_kanimals.length - 1)];

  int number = Random().nextInt(9999);

  bool loading = true;

  void onRewindPressed() async {
    loading = true;
    notifyListeners();

    color = _kcolors[Random().nextInt(_kcolors.length - 1)];
    animal = _kanimals[Random().nextInt(_kcolors.length - 1)];
    number = Random().nextInt(999);

    await Future.delayed(_kloadingTime);

    loading = false;
    notifyListeners();
  }

  Future<bool> onProceedPressed() async {
    try {
      final LocalStorage storage = LocalStorage();
      final User user = storage.user!;

      User newUser = user.copyWith(
        nickname: '$color$animal$number',
      );

      await storage.setUser(newUser);
      await FirestoreService().saveUserData(user: newUser);

      return true;
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'Name Generator Error',
      );
      return false;
    }
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
