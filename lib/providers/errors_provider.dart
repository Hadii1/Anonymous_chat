import 'dart:io';

import 'package:anonymous_chat/providers/connectivity_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry/sentry.dart';

final errorsProvider = StateNotifierProvider(
  (ref) => ErrorNotifier(
    connectivityStream: ref.read(connectivityProvider.stream),
  ),
);

class ErrorNotifier extends StateNotifier<String> {
  ErrorNotifier({required Stream<ConnectivityResult> connectivityStream})
      : super('') {
    connectivityStream.skip(1).listen(
      (event) {
        print(event);
        if (event == ConnectivityResult.none) {
          setError(message: 'Connection Lost');
        } else {
          setError(message: 'Back On Track');
        }
      },
    );
  }

  void setError({
    Object? exception,
    StackTrace? stackTrace,
    String? message,
    String? hint,
    int seconds = 4,
  }) async {
    print(exception);
    print(stackTrace);
    if (exception is PlatformException) {
      print(exception.code);
      print(exception.details);
      print(exception.message);
    } else if (exception is FirebaseException) {
      print(exception.code);
      print(exception.plugin);
      print(exception.message);
    }

    if (message != null) {
      state = message;
    } else {
      switch (exception.runtimeType) {
        case SocketException:
          state = 'Bad Internet Connection';
          break;

        case PlatformException:
          state = 'An Error Occured';
          break;

        case FirebaseAuthException:
          FirebaseAuthException e = (exception as FirebaseAuthException);
          switch (e.code) {
            case 'wrong-password':
              state = 'Invalid password';
              break;
            case 'email-already-in-use':
              state = 'Email address already in use. Please use another one.';
              break;
            case 'invalid-email':
              state =
                  'Your email address is invalid. Please enter a valid address.';
              break;
            case 'weak-password':
              state =
                  'Password not strong enough. Please use a stronger combination.';
              break;

            case 'user-not-found':
              state = 'No user record with this name was found.';
              break;

            case 'too-many-requests':
              state =
                  'Access to this account has been temporarily disabled due to many failed login attempts.';
              break;

            default:
              state = 'Unknown Error Occured.';
              break;
          }
          break;

        default:
          state = 'Unknown Error Occured.';
          break;
      }
    }

    if (exception != null && stackTrace != null) {
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint,
      );
    }

    await Future.delayed(Duration(seconds: seconds));

    state = '';
  }

  void submitError({
    required Object exception,
    required StackTrace stackTrace,
    String? hint,
  }) {
    print(exception);
    print(stackTrace);

    if (exception is PlatformException) {
      print(exception.code);
      print(exception.details);
      print(exception.message);
    } else if (exception is FirebaseException) {
      print(exception.code);
      print(exception.plugin);
      print(exception.message);
    }

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint,
    );
  }
}
