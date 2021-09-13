import 'dart:io';
import 'dart:math';

import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

const _kloadingTime = Duration(seconds: 2);

final nameGeneratorProvider = ChangeNotifierProvider.autoDispose(
  (ref) => NameGeneratorNotifier(
    ref.read(errorsStateProvider.notifier),
    ref.read(loadingProvider.notifier),
  ),
);

class NameGeneratorNotifier extends ChangeNotifier {
  final ErrorsNotifier _errorNotifier;
  final LoadingNotifier _loadingNotifier;

  NameGeneratorNotifier(
    this._errorNotifier,
    this._loadingNotifier,
  ) {
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
      _loadingNotifier.loading = true;
      final storage = ILocalStorage.storage;
      final User user = storage.user!;
// TODO: handle
      // User newUser = user.updateNickname(
      //   nickname: '$color$animal$number',
      // );

      await FirestoreService().saveUserData(user: user);
      await storage.setUser(user);

      _loadingNotifier.loading = false;
      return true;
    } on Exception catch (e, _) {
      _errorNotifier.set(e is SocketException
          ? 'Bad internet connection. Try again.'
          : 'An error occured. Try again please');

      _loadingNotifier.loading = false;
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
