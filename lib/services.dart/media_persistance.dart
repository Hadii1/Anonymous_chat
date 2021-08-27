// // Copyright 2021 Hadi Hammoud
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //     http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

// import 'dart:io';
// import 'dart:typed_data';

// import 'package:anonymous_chat/services.dart/storage.dart';
// import 'package:anonymous_chat/utilities/general_functions.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';

// class MediaPersistance {
//   static final MediaPersistance _instance = MediaPersistance._internal();

//   static late final String directoryPath;

//   MediaPersistance._internal();

//   static Future<void> init() async {
//     directoryPath = (await getApplicationDocumentsDirectory()).path;
//   }

//   Future<void> writeImageToAppDirectory(
//       {required File imageFile, required String name}) async {
//     await retry(
//       f: () async {
//         File file = File(join(MediaPersistance.directoryPath, name));
//         Uint8List b = await imageFile.readAsBytes();
//         await file.writeAsBytes(b);
//       },
//     );
//   }

//   Future<File?> downloadNetworkImage(String name) async {
//     return retry<File?>(f: () async {
//       File file = File(join(MediaPersistance.directoryPath, name));

//       Uint8List? bytes = await FirebaseStorageService().getImage(name: name);
//       if (bytes != null) {
//         await file.writeAsBytes(bytes);
//         return file;
//       } else
//         return null;
//     });
//   }

//   factory MediaPersistance() => _instance;
// }
