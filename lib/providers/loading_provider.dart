import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>(
  (_) => LoadingNotifier(),
);

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  set loading(bool value) => state = value;
}
