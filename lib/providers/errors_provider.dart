import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final errorsStateProvider =
    StateNotifierProvider<ErrorsNotifier, Tuple2<String, bool>>(
  (_) => ErrorsNotifier(),
);

class ErrorsNotifier extends StateNotifier<Tuple2<String, bool>> {
  ErrorsNotifier() : super(Tuple2('', false));

  void set(
    String errorMessage, {
    Duration duration = const Duration(seconds: 3),
  }) {
    state = Tuple2(errorMessage, true);
    Future.delayed(duration).then(
      (_) => state = Tuple2(errorMessage, false),
    );
  }
}
