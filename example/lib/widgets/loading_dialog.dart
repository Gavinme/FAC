import 'dart:async';

import 'package:flutter/material.dart';

import 'dialog.dart';

/// desc：浮窗loading
class LoadingDialog with DialogInterface {
  static LoadingDialog instance;
  @override
  var onDialogDismiss;

  @override
  BuildContext currentContext;

  @override
  bool showing = false;

  @override
  Future<bool> show<bool>(BuildContext context) {
    currentContext = context;
    showing = true;
    showLinkDialog(
      context: context,
      showBarrierColor: false,
      barrierDismissible: false,
      builder: (context) => CommonLoadingWidget(),
    ).then((v) => showing = false);
  }

  static LoadingDialog get() {
    instance ??= LoadingDialog();
    return instance;
  }

  @override
  void cancel() {
    if (showing) {
      Navigator.pop(currentContext);
    }
  }

  @override
  void setOnDialogDismissListener(onDialogDismiss) {
    this.onDialogDismiss = onDialogDismiss;
  }
}

/// 菊花loading
class CommonLoadingWidget extends StatefulWidget {
  final String tip;

  const CommonLoadingWidget({
    Key key,
    this.tip,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommonLoadingWidgetState();
  }
}

class _CommonLoadingWidgetState<CommonLoadingWidget> extends State with TickerProviderStateMixin {
  AnimationController controller;

  _CommonLoadingWidgetState() : super() {
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  void initState() {
    super.initState();
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center, child: buildRotationTransition());
  }

  Widget buildRotationTransition() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RotationTransition(
          alignment: Alignment.center,
          turns: controller,
          child: Image.asset(
            'assets/images/ic_progress_bg.png',
            width: 25,
            height: 25,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
