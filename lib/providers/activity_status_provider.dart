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

import 'dart:async';

import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactActivityStateProvider =
    StateNotifierProvider.autoDispose.family<ContactActivityState, String>(
  (ref, otherUserId) => ContactActivityState(
    otherId: otherUserId,
  ),
);

class ContactActivityState extends StateNotifier<ActivityStatus> {
  ContactActivityState({
    required this.otherId,
  }) : super(ActivityStatus.loading()) {
    init();
  }

  final String otherId;
  final String userId = LocalStorage().user!.id;
  late StreamSubscription subscription;

  void init() {
    subscription = FirestoreService()
        .activityStatusStream(id: otherId)
        .listen((Map<String, dynamic> data) {
      ActivityStatus activityStatus = ActivityStatus.fromMap(data);

      if (activityStatus.state == ActivityStatus.TYPING &&
          activityStatus.chattingWith! != userId) {
        state = ActivityStatus.online();
      } else {
        state = activityStatus;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
}

final userActivityStateProvider = StateNotifierProvider.autoDispose(
  (ref) => UserActivityState(
    errorNotifier: ref.read(errorsProvider),
  ),
);

class UserActivityState extends StateNotifier<ActivityStatus> {
  UserActivityState({
    required this.errorNotifier,
  }) : super(ActivityStatus.online());

  final ErrorNotifier errorNotifier;
  final String? userId = LocalStorage().user?.id;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> set({required ActivityStatus activityStatus}) async {
    try {
      if (userId != null) {
        return _firestoreService.updateUserStatus(
          userId: userId!,
          status: activityStatus.toMap(),
        );
      }
    } on Exception catch (e, s) {
      errorNotifier.submitError(exception: e, stackTrace: s);
    }
  }
}
