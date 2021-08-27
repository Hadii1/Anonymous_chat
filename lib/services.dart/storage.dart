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

// import 'package:anonymous_chat/interfaces/iStorage_service.dart';

// import 'package:firebase_storage/firebase_storage.dart';

// class FirebaseStorageService implements IOnlineStorageService {
//   static final FirebaseStorageService _instance =
//       FirebaseStorageService._internal();

//   factory FirebaseStorageService() => _instance;

//   FirebaseStorageService._internal();

//   final FirebaseStorage _sg = FirebaseStorage.instance;

//   @override
//   Future<void> saveImage({required File file, required String name}) async {
//     Reference ref = _sg.ref().child('images').child(name);

//     await ref.putFile(file);
//   }

//   @override
//   Future<Uint8List?> getImage({required String name}) {
//     return _sg.ref().child('images').child(name).getData();
//   }
// }
