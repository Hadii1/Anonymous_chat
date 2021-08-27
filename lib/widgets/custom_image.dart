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

// import 'package:anonymous_chat/services.dart/media_persistance.dart';

// import 'package:extended_image/extended_image.dart';
// import 'package:path/path.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class CustomImage extends StatefulWidget {
//   final File? file;
//   final String? imageName;
//   final double height;

//   const CustomImage({
//     this.file,
//     this.imageName,
//     required this.height,
//   });

//   @override
//   _CustomImageState createState() => _CustomImageState();
// }

// class _CustomImageState extends State<CustomImage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );
//   }

//   @override
//   void didUpdateWidget(CustomImage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.file != widget.file && mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final ApplicationStyle style = InheritedAppTheme.of(context).style;
//     return AnimatedSwitcher(
//       duration: Duration(milliseconds: 350),
//       child: ExtendedImage.file(
//         widget.file != null
//             ? widget.file!
//             : File(join(MediaPersistance.directoryPath, widget.imageName)),
//         height: widget.height,
//         borderRadius: BorderRadius.circular(8),
//         enableLoadState: true,
//         loadStateChanged: (ExtendedImageState state) {
//           switch (state.extendedImageLoadState) {
//             case LoadState.loading:
//               _animationController.reset();
//               return Container(
//                 height: widget.height,
//                 child: Center(
//                   child: Icon(Icons.image_outlined),
//                 ),
//               );

//             case LoadState.completed:
//               _animationController.forward();

//               return FadeTransition(
//                 opacity: _animationController,
//                 child: ExtendedRawImage(
//                   height: widget.height,
//                   image: state.extendedImageInfo!.image,
//                 ),
//               );
//             case LoadState.failed:
//               _animationController.reset();
//               return Container(
//                 height: widget.height,
//                 child: Center(
//                   child: Icon(Icons.error_outline_sharp),
//                 ),
//               );
//           }
//         },
//       ),
//     );
//   }
// }
