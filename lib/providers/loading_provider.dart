import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateNotifierProvider(
  (_) => LoadingNotifer(),
);

class LoadingNotifer extends StateNotifier<bool> {
  LoadingNotifer() : super(false);

  set isLoading(bool value) => state = value;
}
