import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final bool? isLoading;
  final double? height;

  const LoadingWidget({this.height, this.isLoading});
  @override
  Widget build(BuildContext context) {
    final theme = AppTheming.of(context).style;
    return Consumer(
      builder: (_, watch, __) {
        bool loading = isLoading ?? watch(loadingProvider);
        return loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: height ?? MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.7),
                child: AbsorbPointer(
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: theme.loadingBarColor,
                      size: 25,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink();
      },
    );
  }
}
