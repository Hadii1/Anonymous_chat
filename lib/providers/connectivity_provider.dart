// Copyright 2021 hadihammoud
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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityEvent {
  connected,
  disconnected,
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityState, ConnectivityEvent?>(
  (ref) => ConnectivityState(),
);

class ConnectivityState extends StateNotifier<ConnectivityEvent?> {
  ConnectivityResult? lastState;

  ConnectivityState() : super(null) {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult currentState) {
      // First time
      if (lastState == null) {
        lastState = currentState;
        if (currentState == ConnectivityResult.none)
          state = ConnectivityEvent.disconnected;
        return;
      }

      if (lastState! == ConnectivityResult.none &&
          currentState != ConnectivityResult.none) {
        state = ConnectivityEvent.connected;
      } else if (lastState! != ConnectivityResult.none &&
          currentState == ConnectivityResult.none) {
        state = ConnectivityEvent.disconnected;
      }

      lastState = currentState;
    });
  }
}
