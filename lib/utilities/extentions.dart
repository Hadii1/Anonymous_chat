import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

extension ChangeType on DocumentChangeType {
  DataChangeType changeType() {
    switch (this) {
      case DocumentChangeType.added:
        return DataChangeType.ADDED;
      case DocumentChangeType.modified:
        return DataChangeType.MODIFIED;
      case DocumentChangeType.removed:
        return DataChangeType.DELETED;
    }
  }
}

extension MessageTimeFormat on int {
  String formatDate() {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(this);
    Duration difference = time.difference(DateTime.now());
    if (difference.inDays < 1) {
      bool am = time.hour < 12;
      int hour = time.hour <= 12 ? time.hour : time.hour - 12;
      return '$hour:${time.minute.toString().length == 1 ? '0${time.minute}' : time.minute} ${am ? 'AM' : 'PM'}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays > 7) {
      switch (time.weekday) {
        case 1:
          return 'Mon';
        case 2:
          return 'Tue';
        case 3:
          return 'Wed';
        case 4:
          return 'Thu';
        case 5:
          return 'Fri';
        case 6:
          return 'Sat';
        case 7:
          return 'Sun';
      }
    } else {
      return '${time.day}/${time.month}';
    }
    return 'NOOO';
  }
}

extension LastSeenTimeFormat on ActivityStatus {
  String formatTiming() {
    switch (this.state) {
      case ActivityStatus.LOADING:
        return '';

      case ActivityStatus.ONLINE:
        return 'Online';

      case ActivityStatus.TYPING:
        return 'Typing';

      case ActivityStatus.OFFLINE:
        DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(this.lastSeen!);
        Duration difference = lastSeen.difference(DateTime.now());

        if (difference.inDays > 30) {
          return 'Long time ago';
        } else if (difference.inDays > 7) {
          return 'With in a month';
        } else if (difference.inDays > 2) {
          return '${difference.inDays} days ago';
        } else if (difference.inDays == 1) {
          return 'Yesterday';
        } else {
          return 'Today at ${lastSeen.hour}:${lastSeen.minute.toString().length == 1 ? '0${lastSeen.minute}' : lastSeen.minute} ';
        }

      default:
        throw Exception('activity state isn\'t valid');
    }
  }
}
